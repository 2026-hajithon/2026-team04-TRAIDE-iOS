//
//  OnboardingModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import Foundation

// MARK: - 온보딩 단계 정의
enum OnboardingStep {
    case loginInfo      // 로그인 정보
    case requiredInfo   // 필수 정보 안내
    case sportsTalent   // 운동 재능 입력
    case welcome        // 완료 화면
}
