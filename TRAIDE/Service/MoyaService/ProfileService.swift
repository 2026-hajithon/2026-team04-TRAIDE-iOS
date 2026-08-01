//
//  ProfileService.swift
//  TRAIDE
//
import Foundation
import Moya

protocol ProfileServiceProtocol {
    // 참고: ViewProfileRequest는 모델 구조상 서버 응답(Response)에 가까워 보입니다.
    func fetchProfile(userId: Int) async throws -> ViewProfileRequest
    func fetchMyProfile() async throws -> ViewProfileRequest
    func fetchReviews(userId: Int) async throws -> [ProfileReview]
    func fetchSports() async throws -> [Sport]
    func fetchRegions() async throws -> [Region]
    func fetchRecommendations() async throws -> [ViewProfileRequest]
    func createProfile(request: CreateUserProfile) async throws
    func updateMyProfile(request: UpdateUserProfile) async throws -> ViewProfileRequest
}

final class ProfileService: ProfileServiceProtocol {
    private let provider: MoyaProvider<ProfileRouter>

    init(provider: MoyaProvider<ProfileRouter>? = nil) {
        self.provider = provider ?? APIManager.shared.createProvider(for: ProfileRouter.self)
    }

    func fetchProfile(userId: Int) async throws -> ViewProfileRequest {
        let response = try await request(.userProfile(userId: userId))
        try validate(response)
        return try decodeResult(ViewProfileRequest.self, from: response.data)
    }

    func fetchMyProfile() async throws -> ViewProfileRequest {
        let response = try await request(.myProfile)
        try validate(response)
        return try decodeResult(ViewProfileRequest.self, from: response.data)
    }

    func fetchReviews(userId: Int) async throws -> [ProfileReview] {
        let response = try await request(.reviews(userId: userId))
        try validate(response)
        return try decodeResult([ProfileReview].self, from: response.data)
    }

    func fetchSports() async throws -> [Sport] {
        let response = try await request(.sports)
        try validate(response)
        return try decodeResult([Sport].self, from: response.data)
    }

    func fetchRegions() async throws -> [Region] {
        let response = try await request(.regions)
        try validate(response)
        return try decodeResult([Region].self, from: response.data)
    }

    func fetchRecommendations() async throws -> [ViewProfileRequest] {
        let response = try await request(.recommendations)
        try validate(response)
        let body = try decodeResult(UserRecommendationListResponse.self, from: response.data)
        return body.items
    }

    func createProfile(request: CreateUserProfile) async throws {
        let response = try await self.request(.createMyProfile(request))
        try validate(response)
    }

    func updateMyProfile(request: UpdateUserProfile) async throws -> ViewProfileRequest {
        let response = try await self.request(.updateMyProfile(request))
        try validate(response)
        return try decodeResult(ViewProfileRequest.self, from: response.data)
    }

    /// 서버의 공통 `APIResponse.result` 형식을 우선 사용합니다.
    /// 기존의 래핑되지 않은 응답도 한동안 함께 지원합니다.
    private func decodeResult<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()

        if let response = try? decoder.decode(APIResponse<T>.self, from: data) {
            guard response.isSuccess else {
                throw APIError.serverError(code: response.code, message: response.message)
            }
            guard let result = response.result else {
                throw APIError.decodingError
            }
            return result
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError
        }
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
