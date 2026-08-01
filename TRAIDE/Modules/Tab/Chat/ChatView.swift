//
//  ChatView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI
import Foundation

// MARK: - 메인 채팅 뷰
struct ChatView: View {
    @Environment(NavigationRouter.self) private var router
    @StateObject private var viewModel: ChatViewModel
    @State private var composedText: String = ""
    
    // 테스트 또는 라우팅을 위해 roomId를 주입받도록 설정 (기본값 테스트용 string 지정 가능)
    init(roomId: String = "test_room_id") {
        _viewModel = StateObject(wrappedValue: ChatViewModel(roomId: roomId))
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    var body: some View {
        ZStack {
            Color(._100).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Bar
                HStack(spacing: 12) {
                    Button(action: router.pop, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color("customwhite"))
                    })
                    
                    Text("상대방 아이디")
                        .font(.pretendardBold(18))
                        .foregroundStyle(Color("customwhite"))
                        .padding(.leading, 4)
                    
                    Spacer()
                    
                    Button(action: {}, label: {
                        Text("함께한 기록")
                            .font(.pretendardMedium(12))
                            .foregroundStyle(Color("customwhite"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color(._200))
                            .cornerRadius(12)
                    })
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color(._100).opacity(0.001))
                
                // 날짜 구분선
                Text("2024년 9월 12일")
                    .font(.pretendardRegular(12))
                    .foregroundStyle(Color(._500))
                    .padding(.vertical, 16)
                
                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.messages) { msg in
                                HStack(alignment: .bottom, spacing: 8) {
                                    if msg.isMe {
                                        Spacer()
                                        ChatBubble(text: msg.text, time: msg.time, isMe: msg.isMe)
                                    } else {
                                        Circle().fill(Color(._300)).frame(width: 36, height: 36).padding(.bottom, 4)
                                        ChatBubble(text: msg.text, time: msg.time, isMe: msg.isMe)
                                        Spacer()
                                    }
                                }
                                .padding(.horizontal, 20)
                                .id(msg.id)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    .onChange(of: viewModel.messages.count) {
                        if let lastMessageId = viewModel.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input bar
                HStack(spacing: 12) {
                    Button(action: { router.push(.appointment) }) {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("g_blue"), Color("g_mint")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                            .overlay(Image(systemName: "calendar").foregroundStyle(Color(.customblack)))
                    }
                    
                    HStack {
                        TextField("메시지 보내기", text: $composedText, axis: .vertical)
                            .font(.pretendardRegular(14))
                            .foregroundStyle(Color("customwhite"))
                        
                        Button(action: {
                            let trimmed = composedText.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            
                            let currentTimeString = timeFormatter.string(from: Date())
                            viewModel.sendMessage(text: trimmed, timeString: currentTimeString)
                            composedText = ""
                        }, label: {
                            Image(systemName: "paperplane")
                                .foregroundStyle(Color("customwhite"))
                        })
                        .disabled(viewModel.isSending)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(._200))
                    .cornerRadius(22)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color(._100).opacity(0.9))
            }
            .background(Color(._100).ignoresSafeArea())
        }
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

#Preview {
    ChatView()
        .environment(NavigationRouter())
}
