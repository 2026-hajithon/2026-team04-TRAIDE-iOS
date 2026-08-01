//
//  ChatViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var errorMessage: String?
    @Published var isSending = false
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    let roomId: String

    init(roomId: String) {
        self.roomId = roomId
        Task { await connect() }
    }

    private func connect() async {
        do {
            _ = try await FirebaseSessionService.shared.restoreSessionIfNeeded()
            fetchMessages()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func fetchMessages() {
        listener?.remove()
        listener = db.collection("rooms")
            .document(roomId)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                guard let documents = snapshot?.documents else {
                    self.errorMessage = error?.localizedDescription ?? "메시지를 불러오지 못했습니다."
                    return
                }

                self.messages = documents.compactMap(ChatMessage.init(document:))
            }
    }

    func sendMessage(text: String, timeString: String) {
        guard let currentUserId = FirebaseSessionService.shared.currentUserId else {
            errorMessage = "Firebase 로그인이 필요합니다. 다시 로그인해주세요."
            return
        }
        guard !isSending else { return }
        isSending = true

        let newMessage: [String: Any] = [
            "text": text,
            "senderId": currentUserId,
            "time": timeString,
            "timestamp": FieldValue.serverTimestamp()
        ]

        let roomReference = db.collection("rooms").document(roomId)
        let messageReference = roomReference.collection("messages").document()
        let batch = db.batch()
        batch.setData(newMessage, forDocument: messageReference)
        batch.setData([
            "lastMessage": text,
            "time": timeString,
            "timestamp": FieldValue.serverTimestamp()
        ], forDocument: roomReference, merge: true)

        batch.commit { [weak self] error in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isSending = false
                if let error = error {
                    self.errorMessage = "메시지 전송 실패: \(error.localizedDescription)"
                }
            }
        }
    }

    deinit {
        listener?.remove()
    }
}
