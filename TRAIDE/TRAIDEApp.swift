//
//  TRAIDEApp.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI
import FirebaseCore

#if canImport(UIKit)
import UIKit

// iOS/iPadOS: Use UIApplicationDelegate to configure Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
#endif

@main
struct YourApp: App {
    @StateObject private var container = DIContainer()
    
  #if canImport(UIKit)
  // register app delegate for Firebase setup on iOS/iPadOS
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  #endif

  var body: some Scene {
    WindowGroup {
        RootView()
            .environmentObject(container)
    }
  }
}
