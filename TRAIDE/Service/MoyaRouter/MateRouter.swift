//
//  MateRouter.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import Moya
import Alamofire

enum MateRouter {
    case getMates
    case getRequests
    case sendRequest(userId: Int)
    case cancelRequest(userId: Int)
    case respondToRequest(id: Int, response: FriendRequestResponse)
}

enum FriendRequestResponse: String, Encodable {
    case accept = "ACCEPTED"
    case reject = "REJECTED"
}

private struct FriendRequestResponseBody: Encodable {
    let status: FriendRequestResponse
}

private struct FriendRequestCreateBody: Encodable {
    let receiverId: Int
}

extension MateRouter: APITargetType {
    var baseURL: URL { URL(string: Config.baseURL)! }

    var path: String {
        switch self {
        case .getMates: return "/api/friends"
        case .getRequests: return "/api/friend-requests/received"
        case .sendRequest, .cancelRequest: return "/api/friend-requests"
        case .respondToRequest(let id, _): return "/api/friend-requests/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMates, .getRequests: .get
        case .sendRequest: .post
        case .cancelRequest: .delete
        case .respondToRequest: .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case .getMates, .getRequests:
            return .requestPlain
        case .sendRequest(let userId), .cancelRequest(let userId):
            return .requestJSONEncodable(FriendRequestCreateBody(receiverId: userId))
        case .respondToRequest(_, let response):
            return .requestJSONEncodable(FriendRequestResponseBody(status: response))
        }
    }
}
