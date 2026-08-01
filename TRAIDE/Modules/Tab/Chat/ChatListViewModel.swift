//
//  ChatListViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class ChatListViewModel: ObservableObject {
    @Published var chatRooms: [ChatRoom] = []
    @Published var errorMessage: String?
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    init() {
        Task { await connect() }
    }
    
    private func connect() async {
        do {
            _ = try await FirebaseSessionService.shared.restoreSessionIfNeeded()
            fetchChatRooms()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func fetchChatRooms() {
        // 로그인한 유저의 UID를 가져옵니다.
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "Firebase 로그인이 필요합니다. 다시 로그인해주세요."
            return
        }
        
        // participants 배열에 내 UID가 포함된 채팅방만 실시간으로 수신 (최신순 정렬)
        listener = db.collection("rooms")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                guard let documents = snapshot?.documents else {
                    self.errorMessage = error?.localizedDescription ?? "채팅방을 불러오지 못했습니다."
                    return
                }
                
                self.chatRooms = documents.compactMap(ChatRoom.init(document:))
            }
    }
    
    deinit {
        listener?.remove()
    }
}
