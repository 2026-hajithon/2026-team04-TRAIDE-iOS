//
//  ProfileViewModel.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//
import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var userProfile: ViewProfileRequest?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    private let profileService: ProfileServiceProtocol
    
    init(profileService: ProfileServiceProtocol? = nil) {
        self.profileService = profileService ?? ProfileService()
    }

    var nickname: String { userProfile?.name ?? "프로필" }
    var mainSport: String { userProfile?.sport.name ?? "운동" }
    var proficiency: String { userProfile?.level.rawValue ?? "" }
    var ageAndGender: String {
        guard let profile = userProfile else { return "" }
        return "\(profile.age)세 / \(profile.gender == .male ? "남" : "여")"
    }
    var location: String { userProfile?.region.name ?? "지역 미설정" }
    var mateCount: Int { userProfile?.friendCount ?? 0 }
    var meetCount: Int { userProfile?.appointmentCount ?? 0 }
    var temperatureBpm: Int { 0 }
    var reviews: [MateReview] { [] }
    
    func loadProfile(for userId: Int) {
        Task {
            isLoading = true
            showError = false
            
            do {
                userProfile = try await profileService.fetchProfile(userId: userId)
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
            
            isLoading = false
        }
    }
}
