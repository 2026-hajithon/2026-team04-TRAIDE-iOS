//
//  AuthRouter.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//
import Foundation

enum AuthRouter {
    case login(request: AuthRequest)
    case signUp(request: AuthRequest)
    

    
    var path: String {
        switch self {
        case .login: return "/api/auth/login"
        case .signUp: return "/api/auth/signup"
        }
    }
    
    var method: String {
        return "POST"
    }
    
    func asURLRequest(baseURL: URL) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        switch self {
        case .login(let data), .signUp(let data):
            request.httpBody = try JSONEncoder().encode(data)
        }
        return request
    }
}
