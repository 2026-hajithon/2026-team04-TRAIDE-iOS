//
//  ProfileService.swift
//  TRAIDE
//
import Foundation
import Moya

protocol ProfileServiceProtocol {
    // 참고: ViewProfileRequest는 모델 구조상 서버 응답(Response)에 가까워 보입니다.
    func fetchProfile(userId: Int) async throws -> ViewProfileRequest
    func fetchRecommendations() async throws -> [ViewProfileRequest]
    func createProfile(request: CreateUserProfile) async throws
}

final class ProfileService: ProfileServiceProtocol {
    private let provider: MoyaProvider<ProfileRouter>

    init(provider: MoyaProvider<ProfileRouter>? = nil) {
        self.provider = provider ?? APIManager.shared.createProvider(for: ProfileRouter.self)
    }

    func fetchProfile(userId: Int) async throws -> ViewProfileRequest {
        let response = try await request(.userProfile(userId: userId))
        try validate(response)
        return try JSONDecoder().decode(ViewProfileRequest.self, from: response.data)
    }

    func fetchRecommendations() async throws -> [ViewProfileRequest] {
        let response = try await request(.recommendations)
        try validate(response)
        let body = try JSONDecoder().decode(UserRecommendationListResponse.self, from: response.data)
        return body.items
    }

    func createProfile(request: CreateUserProfile) async throws {
        let response = try await self.request(.createMyProfile(request))
        try validate(response)
    }

    private func validate(_ response: Response) throws {
        guard (200..<300).contains(response.statusCode) else {
            throw APIError.response(data: response.data, statusCode: response.statusCode)
        }
    }

    private func request(_ target: ProfileRouter) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: APIError.moyaError(error))
                }
            }
        }
    }
}
