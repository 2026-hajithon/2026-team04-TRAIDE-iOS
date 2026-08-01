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
    case acceptRequest(id: Int)
    case rejectRequest(id: Int)
}

extension MateRouter: APITargetType {
    var baseURL: URL { URL(string: Config.baseURL)! }

    var path: String {
        switch self {
        case .getMates: return "/api/friends"
        case .getRequests: return "/api/friends-requests"
        case .acceptRequest(let id): return "/api/mates/requests/\(id)/accept"
        case .rejectRequest(let id): return "/api/mates/requests/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getMates, .getRequests: .get
        case .acceptRequest: .post
        case .rejectRequest: .delete
        }
    }

    var task: Moya.Task { .requestPlain }
}
