//
//  Route.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

enum Route: Hashable {
    
    //온보딩
    
    case home
    case onboarding
    case login
    case chat(roomId: String, participantId: String? = nil, participantName: String? = nil)
    case appointment
    case profile
    case otherProfile(ProfileDetail)
    case record(ProfileDetail)
    
}
