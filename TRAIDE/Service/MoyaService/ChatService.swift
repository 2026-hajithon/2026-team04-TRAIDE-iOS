//
//  ChatService.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import FirebaseAuth

/// 백엔드가 발급한 Firebase Custom Token으로 Firebase Auth 세션을 관리합니다.
/// Firebase Auth 자체가 로그인 세션을 Keychain에 유지하므로, 앱 재실행 시에는
/// 유효한 세션이 있으면 저장된 Custom Token을 다시 사용하지 않습니다.
final class FirebaseSessionService {
    static let shared = FirebaseSessionService()

    private let firebaseTokenKey = "firebaseToken"

    private init() {}

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    @discardableResult
    func signIn(firebaseToken: String) async throws -> String {
        guard !firebaseToken.isEmpty else {
            throw FirebaseSessionError.missingToken
        }

        let result = try await Auth.auth().signIn(withCustomToken: firebaseToken)
        guard KeychainManager.shared.save(key: firebaseTokenKey, value: firebaseToken) else {
            try? Auth.auth().signOut()
            throw FirebaseSessionError.tokenStorageFailed
        }
        return result.user.uid
    }

    /// Firebase가 복원한 세션을 우선 사용하고, 세션이 없을 때만 저장된 토큰을 사용합니다.
    @discardableResult
    func restoreSessionIfNeeded() async throws -> String {
        if let uid = currentUserId {
            return uid
        }

        guard let token = KeychainManager.shared.read(key: firebaseTokenKey), !token.isEmpty else {
            throw FirebaseSessionError.missingToken
        }
        return try await signIn(firebaseToken: token)
    }

    func signOut() throws {
        defer {
            _ = KeychainManager.shared.delete(key: firebaseTokenKey)
        }
        try Auth.auth().signOut()
    }
}

enum FirebaseSessionError: LocalizedError {
    case missingToken
    case tokenStorageFailed

    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "Firebase 인증 토큰이 없습니다. 다시 로그인해주세요."
        case .tokenStorageFailed:
            return "Firebase 인증 정보를 안전하게 저장하지 못했습니다."
        }
    }
}
