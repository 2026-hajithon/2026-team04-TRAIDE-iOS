//
//  LoginViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var loginId: String = ""
    @Published var password: String = ""

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    @Published var isLoginSuccessful: Bool = false

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }

    func login() {
        guard !loginId.isEmpty, !password.isEmpty else {
            self.errorMessage = "아이디와 비밀번호를 모두 입력해주세요."
            self.showError = true
            return
        }

        let request = AuthRequest(loginId: loginId, password: password)

        Task {
            isLoading = true
            showError = false

            do {
                let response = try await authService.login(request: request)
                // 화면 전환 전에 Firebase Auth 세션까지 만들어야 채팅 접근이 가능합니다.
                if let firebaseToken = response.firebaseToken, !firebaseToken.isEmpty {
                    _ = try await FirebaseSessionService.shared.signIn(firebaseToken: firebaseToken)
                }

                let tokenProvider = TokenProvider()
                tokenProvider.accessToken = response.accessToken
                guard tokenProvider.accessToken == response.accessToken else {
                    try? FirebaseSessionService.shared.signOut()
                    throw LoginError.accessTokenStorageFailed
                }

                isLoginSuccessful = true
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }

            isLoading = false
        }
    }
}

private enum LoginError: LocalizedError {
    case accessTokenStorageFailed

    var errorDescription: String? {
        "로그인 정보를 안전하게 저장하지 못했습니다. 다시 시도해주세요."
    }
}
