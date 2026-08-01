//
//  DIContainer.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//


import Foundation
import Combine

/// 앱 전역에서 사용할 의존성 주입(Dependency Injection) 컨테이너 클래스
/// ViewModel, Router, UseCase 등 여러 공통 인스턴스를 중앙에서 주입하고 공유하기 위한 용도로 사용됨
class DIContainer: ObservableObject {

    /// 화면 전환을 제어하는 네비게이션 라우터
    @Published var navigationRouter: NavigationRouter



    /// 선택된 탭을 제어
    @Published var selectedTab: TabItem

    /// 백엔드 액세스 토큰을 기준으로 앱의 루트 화면을 결정
    @Published var isAuthenticated: Bool

    /// 현재 앱 실행 중 프로필 화면에서 신청한 메이트 목록
    @Published private(set) var requestedMates: [Mate] = []

    /// DIContainer 초기화 함수
    /// 외부에서 navigationRouter와 useCaseService를 주입받아 사용할 수 있도록 구성
    /// 기본값으로는 각각 새로운 인스턴스를 생성하여 초기화
    init(
        navigationRouter: NavigationRouter = .init(),
        selectedTab: TabItem = .home,
        isAuthenticated: Bool? = nil
    ) {
        self.navigationRouter = navigationRouter
        self.selectedTab = selectedTab
        self.isAuthenticated = isAuthenticated ?? (TokenProvider().accessToken != nil)
    }

    func completeAuthentication() {
        selectedTab = .home
        isAuthenticated = true
        navigationRouter.reset()
    }

    func logout() {
        TokenProvider().accessToken = nil
        try? FirebaseSessionService.shared.signOut()
        selectedTab = .home
        isAuthenticated = false
        navigationRouter.reset()
    }

    func setMateRequest(_ mate: Mate, isRequested: Bool) {
        requestedMates.removeAll { $0.id == mate.id }
        if isRequested {
            requestedMates.append(mate)
        }
    }

    func isMateRequested(id: String) -> Bool {
        requestedMates.contains { $0.id == id }
    }
}
