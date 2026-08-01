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
    private let chatViewModel: ChatViewModel

    init(chatViewModel: ChatViewModel = .preview) {
        self.chatViewModel = chatViewModel
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            
            MateView()
                .tag(TabItem.mate)
                .tabItem {
                    Image(systemName: "person.2.fill")
                    
                    Text("메이트")
                    
                }
            
            HomeView()
                .tag(TabItem.home)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("홈")
                }



            ChatView(viewModel: chatViewModel)
                .tag(TabItem.chat)
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                    Text("채팅")
                }
        }
        .tint(Color("g_blue"))
        .accentColor(Color("g_blue"))
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
