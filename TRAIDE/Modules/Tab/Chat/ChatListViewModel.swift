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

        // Firestore의 arrayContains + orderBy 조합은 별도의 복합 인덱스가 필요합니다.
        // 채팅 목록이 인덱스 배포 여부 때문에 중단되지 않도록 서버에서는 참여자만
        // 필터링하고, 수신한 문서를 앱에서 최신순으로 정렬합니다.
        listener = db.collection("rooms")
            .whereField("participants", arrayContains: currentUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                guard let documents = snapshot?.documents else {
                    let description = error?.localizedDescription ?? ""
                    if description.localizedCaseInsensitiveContains("permission denied")
                        || description.localizedCaseInsensitiveContains("firestore api has not been used") {
                        self.errorMessage = "채팅 서버가 아직 활성화되지 않았습니다. 잠시 후 다시 시도해주세요."
                    } else {
                        self.errorMessage = description.isEmpty ? "채팅방을 불러오지 못했습니다." : description
                    }
                    return
                }

                self.errorMessage = nil
                self.chatRooms = documents
                    .compactMap(ChatRoom.init(document:))
                    .sorted { lhs, rhs in
                        switch (lhs.timestamp, rhs.timestamp) {
                        case let (left?, right?):
                            return left.dateValue() > right.dateValue()
                        case (.some, .none):
                            return true
                        case (.none, .some):
                            return false
                        case (.none, .none):
                            return lhs.id < rhs.id
                        }
                    }
            }
    }

    deinit {
        listener?.remove()
    }
}
