//
//  ProfileRouter.swift
//  TRAIDE
//

import Foundation
import Moya
import Alamofire

enum ProfileRouter {
    case createMyProfile(CreateUserProfile)
    case myProfile
    case updateMyProfile(CreateUserProfile)
    case userProfile(userId: Int)
    case recommendations
}

extension ProfileRouter: APITargetType {
    var sampleData: Data { Data() }

    var baseURL: URL {
        URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .createMyProfile, .myProfile, .updateMyProfile:
            "/api/users/me"
        case .userProfile(let userId):
            "/api/users/\(userId)"
        case .recommendations:
            "/api/users/recommendations"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createMyProfile:
            .post
        case .myProfile, .userProfile, .recommendations:
            .get
        case .updateMyProfile:
            .patch
        }
    }

    var task: Moya.Task {
        switch self {
        case .createMyProfile(let request):
            .requestJSONEncodable(request)
        case .updateMyProfile(let request):
            .requestJSONEncodable(request)
        case .myProfile, .userProfile, .recommendations:
            .requestPlain
        }
    }
}
