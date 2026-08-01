//
//  MoyaProvider.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//


import SwiftUI
import Combine
import Moya
import Alamofire

extension MoyaProvider {
    private func requestDataPublisher(_ target: Target) -> AnyPublisher<Data, APIError> {
        Future<Data, APIError> { promise in
            self.request(target) { result in
                switch result {
                case .success(let response):
                    promise(.success(response.data))
                case .failure(let error):
                    promise(.failure(APIError.moyaError(error)))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func requestResult<T: Decodable>(
        _ target: Target,
        type: T.Type
    ) -> AnyPublisher<T, APIError> {
        return self.requestDataPublisher(target)
            .decode(type: APIResponse<T>.self, decoder: JSONDecoder())
            .tryMap { response in
                if response.isSuccess {
                    if let result = response.result {
                        return result
                    } else {
                        throw APIError.decodingError
                    }
                } else {
                    throw APIError.serverError(code: response.code, message: response.message)
                }
            }
            .mapError { error in
                if let api = error as? APIError {
                    return api
                } else if error is DecodingError {
                    return APIError.decodingError
                } else {
                    return APIError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
    
    func requestStatus(
        _ target: Target
    ) -> AnyPublisher<StatusResponseOnly, APIError> {
        return self.requestDataPublisher(target)
            .decode(type: StatusResponseOnly.self, decoder: JSONDecoder())
            .tryMap { response in
                if response.isSuccess {
                    return response
                } else {
                    throw APIError.serverError(
                        code: response.code,
                        message: response.message
                    )
                }
            }
            .mapError { error in
                if let api = error as? APIError {
                    return api
                } else if error is DecodingError {
                    return APIError.unauthorized
                } else {
                    return APIError.unknown
                }
            }
            .eraseToAnyPublisher()
    }
}
