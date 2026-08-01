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
    case updateMyProfile(UpdateUserProfile)
    case userProfile(userId: Int)
    case recommendations
    case reviews(userId: Int)
    case sports
    case regions
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
        case .reviews(let userId):
            "/api/users/\(userId)/reviews"
        case .sports:
            "/api/sports"
        case .regions:
            "/api/regions"
        }
    }

    var method: Moya.Method {
        switch self {
        case .createMyProfile:
            .post
        case .myProfile, .userProfile, .recommendations, .reviews, .sports, .regions:
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
        case .myProfile, .userProfile, .recommendations, .reviews, .sports, .regions:
            .requestPlain
        }
    }
}
