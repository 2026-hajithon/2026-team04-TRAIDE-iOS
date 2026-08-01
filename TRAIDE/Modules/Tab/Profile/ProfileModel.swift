//
//  ProfileModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import Foundation


struct MateReview: Identifiable {
    let id = UUID()
    let author: String
    let content: String
}
