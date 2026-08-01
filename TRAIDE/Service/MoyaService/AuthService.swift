//
//  AuthService.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation

protocol AuthServiceProtocol {
    func login(request: AuthRequest) async throws -> AuthResponse
    func signUp(request: AuthRequest) async throws -> AuthResponse
}

final class AuthService: AuthServiceProtocol {
    private let baseURL = URL(string: Config.baseURL)!

    func login(request: AuthRequest) async throws -> AuthResponse {
        try await execute(.login(request: request))
    }

    func signUp(request: AuthRequest) async throws -> AuthResponse {
        try await execute(.signUp(request: request))
    }

    private func execute(_ route: AuthRouter) async throws -> AuthResponse {
        let (data, response) = try await URLSession.shared.data(
            for: route.asURLRequest(baseURL: baseURL)
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw APIError.response(data: data, statusCode: httpResponse.statusCode)
        }

        if let wrapped = try? JSONDecoder().decode(APIResponse<AuthResponse>.self, from: data) {
            guard wrapped.isSuccess, let result = wrapped.result else {
                throw APIError.serverError(code: wrapped.code, message: wrapped.message)
            }
            return result
        }

        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
}
