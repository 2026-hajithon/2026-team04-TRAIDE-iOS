//
//  ImageRouter.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//
import Foundation

enum ImageRouter {
    case upload(imageData: Data)
    

    
    var path: String {
        return "/api/images/upload"
    }
    
    func asURLRequest(baseURL: URL) throws -> URLRequest {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        // Multipart/form-data 설정 필요
        request.setValue("multipart/form-data; boundary=Boundary-\(UUID().uuidString)", forHTTPHeaderField: "Content-Type")
        
        switch self {
        case .upload(let imageData):
            // 실제 구현 시 multipart 바디 생성 로직 추가 필요
            request.httpBody = imageData
        }
        return request
    }
}
