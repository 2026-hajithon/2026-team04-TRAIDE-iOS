//
//  APITargetType.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation
import Moya

protocol APITargetType: TargetType {}

extension APITargetType {
    var sampleData: Data { Data() }

    var headers: [String: String]? {
        switch task {
        case .requestJSONEncodable, .requestParameters:
            return ["Content-Type": "application/json"]
        case .uploadMultipart:
            return ["Content-Type": "multipart/form-data"]
        default:
            return nil
        }
    }
    
    var validationType: ValidationType {
        return .customCodes((100..<600).filter { $0 != 401 })
    }
}
