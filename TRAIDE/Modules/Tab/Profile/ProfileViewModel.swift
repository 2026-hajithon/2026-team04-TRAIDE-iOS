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
    @Published var reviews: [ProfileReview] = []
    @Published var sports: [Sport] = []
    @Published var regions: [Region] = []
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    
    private let profileService: ProfileServiceProtocol
    
    init(profileService: ProfileServiceProtocol? = nil) {
        self.profileService = profileService ?? ProfileService()
    }

    var nickname: String { userProfile?.name ?? "프로필" }
    var mainSport: String { userProfile?.sport.name ?? "운동" }
    var proficiency: String {
        switch userProfile?.level {
        case .beginner: "워밍업"
        case .intermediate: "동네 에이스"
        case .advanced: "고인물"
        case nil: ""
        }
    }
    var ageAndGender: String {
        guard let profile = userProfile else { return "" }
        return "\(profile.age)세 / \(profile.gender == .male ? "남" : "여")"
    }
    var location: String { userProfile?.region.name ?? "지역 미설정" }
    var mateCount: Int { userProfile?.friendCount ?? 0 }
    var meetCount: Int { userProfile?.appointmentCount ?? 0 }
    var averageRating: Double { userProfile?.averageRating ?? 0 }
    var reviewCount: Int { userProfile?.reviewCount ?? 0 }
    
    func loadMyProfile() async {
        isLoading = true
        showError = false

        do {
            let profile = try await profileService.fetchMyProfile()
            userProfile = profile
            async let reviewsRequest = profileService.fetchReviews(userId: profile.id)
            async let sportsRequest = profileService.fetchSports()
            async let regionsRequest = profileService.fetchRegions()
            (reviews, sports, regions) = try await (reviewsRequest, sportsRequest, regionsRequest)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    func updateProfile(request: UpdateUserProfile) async -> Bool {
        isLoading = true
        showError = false

        do {
            userProfile = try await profileService.updateMyProfile(request: request)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            return false
        }
    }
}
