//
//  TRAIDEApp.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI
import FirebaseCore

@main
struct TRAIDEApp: App {
    init() {
        // 설정 파일이 없는 개발/프리뷰 빌드는 Firebase 없이 실행합니다.
        if FirebaseApp.app() == nil,
           Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
