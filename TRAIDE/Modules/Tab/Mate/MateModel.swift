import Foundation

struct Mate: Identifiable, Hashable {
    let id: String
    let nickname: String
    let teachingSport: String
    let learningSport: String
    let age: Int?
    let district: String?
    let imageURL: String?
    let appointmentCount: Int
    let chatRoomID: String?
}

struct MateRequest: Identifiable, Hashable {
    let id: String
    let mate: Mate
}
