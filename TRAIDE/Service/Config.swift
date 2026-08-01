//
//  Config.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation

enum Config {
    static var baseURL: String {
        // Info.plist에 등록된 BASE_URL 값을 가져옵니다.
        guard let url = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("BASE_URL이 Info.plist에 설정되지 않았습니다.")
        }
        return url
    }
}
