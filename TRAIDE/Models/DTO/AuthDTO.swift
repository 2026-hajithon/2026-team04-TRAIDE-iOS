//
//  AuthDTO.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation



/// 로그인 요청 구조체 - 로그인, 회원가입 시 사용
struct AuthRequest: Codable{
    let loginId: String
    let password: String
}


/// 로그인 응답 구조체 - 로그인, 회원가입 시 사용
struct AuthResponse: Codable {
    let userId: Int
    let accessToken: String
    /// Firebase 토큰 발급에 실패한 경우 서버가 null을 반환할 수 있습니다.
    let firebaseToken: String?
}

