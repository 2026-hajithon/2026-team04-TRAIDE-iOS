//
//  CommonResponse.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//


import Foundation

// 최상위 응답 모델
public struct APIResponse<T: Decodable>: Decodable {
    public let isSuccess: Bool
    public let code: String
    public let message: String
    public let result: T?
}

// result가 없는 응답 모델
public struct StatusResponseOnly: Codable {
    public let isSuccess: Bool
    public let code: String
    public let message: String

    enum CodingKeys: String, CodingKey {
        case isSuccess = "isSuccess"
        case code = "code"
        case message = "message"
    }
}
