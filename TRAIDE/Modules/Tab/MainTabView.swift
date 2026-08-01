//
//  MainTabView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

/// 앱 루트 탭뷰.

struct MainTabView: View {
    @State private var selectedTab: TabItem = .home

    var body: some View {
        ZStack(alignment: .bottom) {



        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch selectedTab {
        case .mate:
            MateView()
        case .home:
            HomeView()
        case .chat:
            ChatView()
        }
    }
}

#Preview {
    MainTabView()
}
