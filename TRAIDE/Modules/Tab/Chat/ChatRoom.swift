//
//  ChatRoom.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import FirebaseFirestore

struct ChatRoom: Identifiable {
    let id: String
    let name: String
    let lastMessage: String
    let time: String
    let timestamp: Timestamp?
    let unreadCount: Int
    let participants: [String] // 참여 중인 유저들의 UID 배열

    nonisolated init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String,
              let lastMessage = data["lastMessage"] as? String,
              let time = data["time"] as? String,
              let unreadCount = data["unreadCount"] as? Int,
              let participants = data["participants"] as? [String] else {
            return nil
        }

        id = document.documentID
        self.name = name
        self.lastMessage = lastMessage
        self.time = time
        timestamp = data["timestamp"] as? Timestamp
        self.unreadCount = unreadCount
        self.participants = participants
    }
}
