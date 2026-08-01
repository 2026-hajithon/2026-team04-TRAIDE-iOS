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
    func sendRequest(to userId: Int) async throws
    func cancelRequest(to userId: Int) async throws
    func acceptRequest(id: Int) async throws
    func rejectRequest(id: Int) async throws
}

final class MateService: MateServiceProtocol {
    private let provider: MoyaProvider<MateRouter>

    init(provider: MoyaProvider<MateRouter>? = nil) {
        self.provider = provider ?? APIManager.shared.createProvider(for: MateRouter.self)
    }

    func fetchMates() async throws -> [MateResponse] {
        try await requestItems(.getMates, as: MateResponse.self)
    }

    func fetchRequests() async throws -> [MateRequestResponse] {
        try await requestItems(.getRequests, as: MateRequestResponse.self)
    }

    func sendRequest(to userId: Int) async throws {
        try await requestStatus(.sendRequest(userId: userId))
    }

    func cancelRequest(to userId: Int) async throws {
        try await requestStatus(.cancelRequest(userId: userId))
    }

    func acceptRequest(id: Int) async throws {
        try await requestStatus(.respondToRequest(id: id, response: .accept))
    }

    func rejectRequest(id: Int) async throws {
        try await requestStatus(.respondToRequest(id: id, response: .reject))
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

    private func requestItems<T: Decodable>(_ target: MateRouter, as type: T.Type) async throws -> [T] {
        let response: Response = try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: APIError.moyaError(error))
                }
            }
        }

        guard (200..<300).contains(response.statusCode) else {
            throw APIError.response(data: response.data, statusCode: response.statusCode)
        }

        do {
            return try JSONDecoder()
                .decode(MateListResponse<T>.self, from: response.data)
                .items
        } catch {
            throw APIError.decodingError
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
