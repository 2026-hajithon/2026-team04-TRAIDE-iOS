import Foundation
import Combine
import Moya

@MainActor
final class SignupViewModel: ObservableObject {
    // MARK: - Step 1: 계정 정보
    @Published var loginId: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""

    // MARK: - Step 2: 기본 정보
    @Published var name: String = ""
    @Published var gender: String = "" // "MALE", "FEMALE"
    @Published var age: String = ""

    // MARK: - Step 3: 운동 성향
    @Published var sportId: Int? = nil
    @Published var level: String = ""  // "BEGINNER", "INTERMEDIATE", "ADVANCED"
    @Published var regionId: Int? = nil

    // MARK: - View State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    @Published var isSignupSuccessful: Bool = false

    private let authService: AuthServiceProtocol
    private let profileService: ProfileServiceProtocol
    private var hasCreatedAccount = false

    init(
        authService: AuthServiceProtocol? = nil,
        profileService: ProfileServiceProtocol? = nil
    ) {
        self.authService = authService ?? AuthService()
        self.profileService = profileService ?? ProfileService()
    }

    var isPasswordMatching: Bool {
        guard !password.isEmpty, !passwordConfirm.isEmpty else { return false }
        return password == passwordConfirm
    }

    var isLoginInfoValid: Bool {
        !loginId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && password.count >= 8
            && isPasswordMatching
    }

    var isBasicInfoValid: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              trimmedName.count <= 30,
              !gender.isEmpty,
              let age = Int(age) else {
            return false
        }
        return (14...100).contains(age)
    }

    func submitSignup() {
        let trimmedLoginId = loginId.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard isLoginInfoValid else {
            self.errorMessage = "아이디를 입력하고 비밀번호를 8자 이상으로 설정해주세요."
            self.showError = true
            return
        }

        guard isBasicInfoValid else {
            self.errorMessage = "이름과 성별을 입력하고 나이는 14세부터 100세 사이로 설정해주세요."
            self.showError = true
            return
        }

        guard let sportId = sportId, let regionId = regionId else {
            self.errorMessage = "종목과 지역을 모두 선택해주세요."
            self.showError = true
            return
        }

        guard let ageInt = Int(age) else {
            self.errorMessage = "나이는 숫자로 입력해주세요."
            self.showError = true
            return
        }

        let authRequest = AuthRequest(loginId: trimmedLoginId, password: password)

        Swift.Task {
            isLoading = true
            showError = false

            do {
                // 프로필 생성만 실패한 경우에는 이미 생성된 계정으로 다시 시도합니다.
                if !hasCreatedAccount {
                    let authResponse = try await authService.signUp(request: authRequest)
                    let tokenProvider = TokenProvider()
                    tokenProvider.accessToken = authResponse.accessToken
                    guard tokenProvider.accessToken == authResponse.accessToken else {
                        throw SignupError.accessTokenStorageFailed
                    }

                    if let firebaseToken = authResponse.firebaseToken, !firebaseToken.isEmpty {
                        _ = try? await FirebaseSessionService.shared.signIn(firebaseToken: firebaseToken)
                    }
                    hasCreatedAccount = true
                }

                let profileRequest = CreateUserProfile(
                    name: trimmedName,
                    age: ageInt,
                    gender: gender,
                    sportId: sportId,
                    level: level,
                    regionId: regionId
                )
                try await profileService.createProfile(request: profileRequest)

                isSignupSuccessful = true
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }

    private func handleError(_ error: Error) {
        if let moyaError = error as? MoyaError,
           case let .statusCode(response) = moyaError {
            self.errorMessage = response.statusCode == 409 ? "이미 사용 중인 아이디입니다." : "서버 오류: \(response.statusCode)"
        } else {
            self.errorMessage = error.localizedDescription
        }
        self.showError = true
    }
}

private enum SignupError: LocalizedError {
    case accessTokenStorageFailed

    var errorDescription: String? {
        "로그인 정보를 안전하게 저장하지 못했습니다. 다시 시도해주세요."
    }
}
