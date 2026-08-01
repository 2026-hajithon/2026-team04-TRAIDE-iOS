//
//  TokenProvider.swift
//  Plantory
//
//  Created by 주민영 on 7/30/25.
//

import Foundation

class TokenProvider: TokenProviding {
    private let keyChain = KeychainService.shared
    
    var accessToken: String? {
        get {
            if let userInfo = keyChain.loadToken(), !userInfo.accessToken.isEmpty {
                return userInfo.accessToken
            }

            // Migrate tokens saved by the previous authentication implementation.
            if let legacyToken = KeychainManager.shared.read(key: "accessToken"),
               !legacyToken.isEmpty {
                keyChain.saveToken(TokenInfo(accessToken: legacyToken))
                return legacyToken
            }
            return nil
        }
        set {
            guard let newValue, !newValue.isEmpty else {
                _ = keyChain.deleteToken()
                _ = KeychainManager.shared.delete(key: "accessToken")
                return
            }
            keyChain.saveToken(TokenInfo(accessToken: newValue))
            _ = KeychainManager.shared.delete(key: "accessToken")
        }
    }
    

    

    
}
