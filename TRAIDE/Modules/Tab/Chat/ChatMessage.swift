//
//  ChatMessage.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

// MARK: - 데이터 모델
struct ChatMessage: Identifiable {
    let id: String
    let text: String
    let senderId: String
    let time: String
    let timestamp: Timestamp?
    
    var isMe: Bool {
        return senderId == Auth.auth().currentUser?.uid
    }

    nonisolated init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let text = data["text"] as? String,
              let senderId = data["senderId"] as? String,
              let time = data["time"] as? String else {
            return nil
        }

        id = document.documentID
        self.text = text
        self.senderId = senderId
        self.time = time
        timestamp = data["timestamp"] as? Timestamp
    }
}
