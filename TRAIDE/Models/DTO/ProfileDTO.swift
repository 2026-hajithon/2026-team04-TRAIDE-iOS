//
//  ProfileDTO.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation


struct ViewProfileRequest: Codable {
    let id: Int
    let loginId: String
    let name: String
    let imageUrl: String
    let age: Int
    let gender: Gender
    let sport: Sport
    let level: Level
    let region: Region
    let friendCount: Int
    let appointmentCount: Int
    let averageRating: Double
    let reviewCount: Int
    let createdAt: String
    let updatedAt: String

        // MARK: - Enums
    enum Gender: String, Codable {
        case male = "MALE"
        case female = "FEMALE"
    }

    enum Level: String, Codable {
        case beginner = "BEGINNER"
        case intermediate = "INTERMEDIATE"
        case advanced = "ADVANCED"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        loginId = try container.decodeIfPresent(String.self, forKey: .loginId) ?? ""
        name = try container.decode(String.self, forKey: .name)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        age = try container.decode(Int.self, forKey: .age)
        gender = try container.decode(Gender.self, forKey: .gender)
        sport = try container.decode(Sport.self, forKey: .sport)
        level = try container.decode(Level.self, forKey: .level)
        region = try container.decode(Region.self, forKey: .region)
        friendCount = try container.decodeIfPresent(Int.self, forKey: .friendCount) ?? 0
        appointmentCount = try container.decodeIfPresent(Int.self, forKey: .appointmentCount) ?? 0
        averageRating = try container.decodeIfPresent(Double.self, forKey: .averageRating) ?? 0
        reviewCount = try container.decodeIfPresent(Int.self, forKey: .reviewCount) ?? 0
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
    }
}

struct UserRecommendationListResponse: Decodable {
    let items: [ViewProfileRequest]
}

// MARK: - Sport
struct Sport: Codable {
    let id: Int
    let name: String
}

// MARK: - Region
struct Region: Codable {
    let id: Int
    let name: String
}

struct CreateUserProfile: Codable{
    let name: String
    let age: Int
    let gender: String
    let sportId: Int
    let level: String
    let regionId: Int
}
