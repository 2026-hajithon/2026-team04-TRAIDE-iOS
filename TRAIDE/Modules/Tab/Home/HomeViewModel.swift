//
//  HomeViewModel.swift
//  TRAIDE
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var profiles: [ViewProfileRequest] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var shouldResetAuthentication = false

    private let profileService: ProfileServiceProtocol

    init(profileService: ProfileServiceProtocol? = nil) {
        self.profileService = profileService ?? ProfileService()
    }

    func loadProfiles(force: Bool = false) async {
        guard force || profiles.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profiles = try await profileService.fetchRecommendations()
        } catch APIError.unauthorized {
            shouldResetAuthentication = true
        } catch APIError.serverError(let code, _) where code == "PROFILE_NOT_FOUND" {
            shouldResetAuthentication = true
        } catch {
            errorMessage = "프로필을 불러오지 못했어요."
        }
    }
}
