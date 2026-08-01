//
//  ChatListView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var viewModel = ChatListViewModel()
    @State private var query: String = ""

    var body: some View {
        
        NavigationStack {
            ZStack {
                Color(._100).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top bar
                    HStack {
                        Text("채팅")
                            .font(.pretendardBold(22))
                            .foregroundStyle(Color("customwhite"))
                        Spacer()
                        
                        
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .background(Color(._100))
                    

                    
                    // List
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: []) {
                            ForEach(filteredRooms, id: \.id) { room in
                                // ChatView로 이동하는 네비게이션 링크 추가
                                NavigationLink(destination: ChatView(roomId: room.id)) {
                                    conversationRow(room)
                                        .background(Color(._100))
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain) // 기본 버튼 스타일 제거
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true) // 기본 네비게이션 바 숨김 처리 (커스텀 Top bar 사용을 위함)
            .alert("채팅 오류", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            }
        }
    }
    
    // 뷰모델의 데이터를 바탕으로 검색 필터링 적용
    private var filteredRooms: [ChatRoom] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty { return viewModel.chatRooms }
        return viewModel.chatRooms.filter { $0.name.contains(q) || $0.lastMessage.contains(q) }
    }
    
    @ViewBuilder
    private func conversationRow(_ room: ChatRoom) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(Color(._300)).frame(width: 48, height: 48)
                Image(systemName: "person.fill").foregroundStyle(Color(._500))
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(room.name)
                        .font(.pretendardMedium(16))
                        .foregroundStyle(Color("customwhite"))
                    Spacer()
                    Text(room.time)
                        .font(.pretendardRegular(12))
                        .foregroundStyle(Color(._400))
                }
                HStack(spacing: 6) {
                    Text(room.lastMessage)
                        .lineLimit(1)
                        .font(.pretendardRegular(14))
                        .foregroundStyle(Color(._500))
                    Spacer()
                    if room.unreadCount > 0 {
                        Text("\(room.unreadCount)")
                            .font(.pretendardBold(12))
                            .foregroundStyle(Color("customblack"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(._100))
        .overlay(Divider().background(Color.white.opacity(0.06)), alignment: .bottom)
    }
}

#Preview {
    ChatListView()
}
