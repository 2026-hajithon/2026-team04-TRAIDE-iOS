//
//  MainTabView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $container.selectedTab) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    // 커스텀 이미지가 아닌 시스템 아이콘(SF Symbols)을 사용할 때는 systemImage 파라미터를 사용합니다.
                    Tab(
                        "",
                        systemImage: getIconName(for: tab, isSelected: container.selectedTab == tab),
                        value: tab,
                        content: {
                            tabView(tab: tab)
                        }
                    )
                }
            }
            .environmentObject(container)
        }
        .toolbarBackground(.customwhite, for: .tabBar)
        .ignoresSafeArea(.keyboard)
        .navigationBarBackButtonHidden(true)
    }

    private func getIconName(for tab: TabItem, isSelected: Bool) -> String {
        switch tab {
        case .home:
            return isSelected ? "house.fill" : "house"
        case .chat:
            return isSelected ? "message.fill" : "message"
        case .mate:
            return isSelected ? "person.2.fill" : "person.2"
        }
    }

    /// 각 탭에 해당하는 뷰
    @ViewBuilder
    private func tabView(tab: TabItem) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .chat:
            ChatListView()
        case .mate:
            MateView()
        }
    }
}

#Preview {
    MainTabView()
}
