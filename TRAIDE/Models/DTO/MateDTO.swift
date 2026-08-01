//
//  MateDTO.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation

struct MateListResponse<Item: Decodable>: Decodable {
    let items: [Item]
}

// MARK: - 메이트(친구) 목록 응답 DTO
struct MateResponse: Codable, Identifiable {
    let id: Int
    let name: String
    let sport: SportInfo
    let region: RegionInfo
    let imageUrl: String?
    let appointmentCount: Int
    let chatRoomId: String?

    private enum CodingKeys: String, CodingKey {
        case id, name, sport, region, imageUrl, appointmentCount, chatRoomId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sport = try container.decode(SportInfo.self, forKey: .sport)
        region = try container.decode(RegionInfo.self, forKey: .region)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        appointmentCount = try container.decodeIfPresent(Int.self, forKey: .appointmentCount) ?? 0
        chatRoomId = try container.decodeIfPresent(String.self, forKey: .chatRoomId)
    }
}

struct MateRequestResponse: Decodable, Identifiable {
    let id: Int
    let user: MateRequestUserResponse

    private enum CodingKeys: String, CodingKey {
        case id
        case requestId
        case user
        case requester
        case mate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
            ?? container.decode(Int.self, forKey: .requestId)
        user = try container.decodeIfPresent(MateRequestUserResponse.self, forKey: .user)
            ?? container.decodeIfPresent(MateRequestUserResponse.self, forKey: .requester)
            ?? container.decode(MateRequestUserResponse.self, forKey: .mate)
    }
}

struct MateRequestUserResponse: Decodable {
    let id: Int
    let name: String
    let sport: SportInfo
    let region: RegionInfo?
    let imageUrl: String?
    let age: Int?
    let gender: String?
    let level: String?
}

// MARK: - 하위 중첩 객체: 종목 정보
struct SportInfo: Codable {
    let id: Int
    let name: String
}

// MARK: - 하위 중첩 객체: 지역 정보
struct RegionInfo: Codable {
    let id: Int
    let name: String
}
