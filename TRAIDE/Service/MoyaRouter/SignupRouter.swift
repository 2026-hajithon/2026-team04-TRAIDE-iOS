//
//  SignupRouter.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import Moya
import Alamofire

enum SignupRouter {
    case submitSignup(request: AuthRequest)
}

extension SignupRouter: TargetType {
    var sampleData: Data { Data() }

    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .submitSignup:
            return "/api/auth/signup"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .submitSignup:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .submitSignup(let request):
            return .requestJSONEncodable(request)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
