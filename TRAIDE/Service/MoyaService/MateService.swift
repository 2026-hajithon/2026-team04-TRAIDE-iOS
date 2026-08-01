//
//  MateService.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import Combine
import Moya

protocol MateServiceProtocol {
    func fetchMates() async throws -> [MateResponse]
    func fetchRequests() async throws -> [MateRequestResponse]
    func acceptRequest(id: Int) async throws
    func rejectRequest(id: Int) async throws
}

final class MateService: MateServiceProtocol {
    private let provider: MoyaProvider<MateRouter>

    init(provider: MoyaProvider<MateRouter>? = nil) {
        self.provider = provider ?? APIManager.shared.createProvider(for: MateRouter.self)
    }

    func fetchMates() async throws -> [MateResponse] {
        try await requestResult(.getMates, as: [MateResponse].self)
    }

    func fetchRequests() async throws -> [MateRequestResponse] {
        try await requestResult(.getRequests, as: [MateRequestResponse].self)
    }

    func acceptRequest(id: Int) async throws {
        try await requestStatus(.acceptRequest(id: id))
    }

    func rejectRequest(id: Int) async throws {
        try await requestStatus(.rejectRequest(id: id))
    }

    private func requestResult<T: Decodable>(_ target: MateRouter, as type: T.Type) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            provider.requestResult(target, type: type)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion { continuation.resume(throwing: error) }
                    },
                    receiveValue: { continuation.resume(returning: $0) }
                )
                .store(in: &cancellables)
        }
    }

    private func requestStatus(_ target: MateRouter) async throws {
        try await withCheckedThrowingContinuation { continuation in
            provider.requestStatus(target)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion { continuation.resume(throwing: error) }
                    },
                    receiveValue: { _ in continuation.resume(returning: ()) }
                )
                .store(in: &cancellables)
        }
    }

    private var cancellables = Set<AnyCancellable>()
}
