//
//  AccessTokenRefresher.swift
//  Plantory
//
//  Created by 주민영 on 7/30/25.
//

import Foundation
import Alamofire

class AccessTokenRefresher: @unchecked Sendable, RequestInterceptor {
    private var tokenProviding: TokenProviding
    private var isRefreshing: Bool = false
    private var requestToRetry: [(RetryResult) -> Void] = []
    
    init(tokenProviding: TokenProviding) {
        self.tokenProviding = tokenProviding
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var urlRequest = urlRequest
        if let accessToken = tokenProviding.accessToken {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount < 1,
              let response = request.task?.response as? HTTPURLResponse,
              [401].contains(response.statusCode) else {
            return completion(.doNotRetry)
        }
        // Token refresh endpoint is not available yet. Failing the original request
        // lets the caller handle the unauthorized state instead of leaving it pending.
        completion(.doNotRetry)
    }
}

extension Notification.Name {
    static let sessionExpired = Notification.Name("sessionExpired")
}
