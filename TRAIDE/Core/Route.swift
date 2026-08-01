//
//  Route.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

enum Route: Hashable {
    
    //온보딩
    
    case basicInfo       // 기본 정보 입력
    case loginInfo       // 로그인 정보 입력
    case profile         // 프로필 설정
    case sportsTalent    // 운동 재능 입력
    case welcome         // 완료/시작 화면
    
    case home
    case onboarding
    case login
}
