//
//  TokenKeychain.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation

protocol TokenProviding {
    var accessToken: String? { get set }
}

struct TokenInfo: Codable {
    var accessToken: String
}
