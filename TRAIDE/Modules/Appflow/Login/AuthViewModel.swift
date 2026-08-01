//
//  AuthViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//
import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var loginId = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol? = nil) {
        self.authService = authService ?? AuthService()
    }

    func login() async {
        isLoading = true
        let request = AuthRequest(loginId: loginId, password: password)
        do {
            let response = try await authService.login(request: request)
            if let firebaseToken = response.firebaseToken, !firebaseToken.isEmpty {
                _ = try await FirebaseSessionService.shared.signIn(firebaseToken: firebaseToken)
            }
            TokenProvider().accessToken = response.accessToken
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
