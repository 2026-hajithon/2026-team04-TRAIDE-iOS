//
//  RootView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var container: DIContainer

    var body: some View {
        @Bindable var router = container.navigationRouter

        NavigationStack(path: $router.path) {
            LoginView()
                .navigationDestination(for: Route.self) { route in
                    destination(for: route)
                }
        }
        .environment(router)
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .home:
            MainTabView()
        case .onboarding:
            OnboardingView()
        case .login:
            LoginView()
        case .chat(let roomId):
            ChatView(roomId: roomId)
        case .appointment:
            ScheduleRegistrationView()
        case .otherProfile(let profile):
            OtherProfileView(profile: profile)
        case .record(let profile):
            ActivityRecordView(profile: profile)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(DIContainer())
}
