//
//  APIError.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import Foundation
import Moya

enum APIError: Error {
    case decodingError
    case moyaError(MoyaError)
    case serverError(code: String, message: String)
    case unauthorized
    case forbidden
    case notFound
    case unknown
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .decodingError:
            return "디코딩에 실패했어요."
        case .moyaError(let error):
            return error.localizedDescription
        case .serverError(_, let message):
            return message
        case .unauthorized:
            return "로그인이 필요해요."
        case .forbidden:
            return "접근 권한이 없어요."
        case .notFound:
            return "요청한 리소스를 찾을 수 없어요."
        case .unknown:
            return "알 수 없는 오류가 발생했어요."
        }
    }
}

extension APIError {
    static func response(data: Data, statusCode: Int) -> APIError {
        if let payload = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let code = payload["code"] as? String,
           let message = payload["message"] as? String {
            return .serverError(code: code, message: message)
        }

        switch statusCode {
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        default:
            return .serverError(
                code: String(statusCode),
                message: "요청을 처리하지 못했습니다. 잠시 후 다시 시도해주세요."
            )
        }
    }
}
