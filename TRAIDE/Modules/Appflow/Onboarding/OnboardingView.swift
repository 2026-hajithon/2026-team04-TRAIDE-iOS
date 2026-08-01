//
//  OnboardingView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

// MARK: - 공통 레이아웃 컴포넌트
struct OnboardingLayout<Content: View>: View {
    let title: String
    let buttonText: String
    let isButtonDisabled: Bool
    let showBackButton: Bool

    let backAction: () -> Void
    let nextAction: () -> Void

    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            // 커스텀 네비게이션 바 (뒤로 가기)
            HStack {
                if showBackButton {
                    Button(action: {
                        backAction()
                    }, label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color("customwhite"))
                    })
                }
                Spacer()
            }
            .frame(height: 44)
            .padding(.bottom, -10)

            // 공통 타이틀
            Text(title)
                .font(.pretendardBold(24))
                .foregroundStyle(Color("customwhite"))
                .lineSpacing(6)

            // 컨텐츠 영역
            content

            Spacer()

            // 공통 하단 버튼
            MainBigButton(
                text: buttonText,
                isDisabled: isButtonDisabled,
                action: nextAction
            )
        }
        .padding(.horizontal, 20)
        .background(Color(._100).ignoresSafeArea())
    }
}

// MARK: - 메인 온보딩 뷰
struct OnboardingView: View {
    @Environment(NavigationRouter.self) private var router
    @EnvironmentObject private var container: DIContainer
    @State private var currentStep: OnboardingStep = .loginInfo
    @StateObject private var viewModel = SignupViewModel() // 뷰모델 연동

    @State private var isRegionSheetPresented: Bool = false

    // UI 표시용 상태 변수 (선택된 텍스트를 저장하고 ViewModel의 ID로 변환하여 전달)
    @State private var selectedSportName: String = ""
    @State private var selectedRegionName: String = ""

    private let seoulDistricts: [String] = [
        "강남구","강동구","강북구","강서구","관악구","광진구","구로구","금천구","노원구","도봉구","동대문구","동작구","마포구","서대문구","서초구","성동구","성북구","송파구","양천구","영등포구","용산구","은평구","종로구","중구","중랑구"
    ]

    var body: some View {
        ZStack {
            Color(._100).ignoresSafeArea()

            switch currentStep {
            case .loginInfo:
                loginInfoStep
            case .basicInfo:
                basicInfoStep
            case .profile:
                profileStep
            case .sportsTalent:
                sportsTalentStep
            case .welcome:
                welcomeStep
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
        // 로딩 및 에러 처리
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .alert("알림", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "오류가 발생했습니다.")
        }
        // 회원가입 성공 시 메인으로 이동
        .onChange(of: viewModel.isSignupSuccessful) { _, isSuccess in
            if isSuccess {
                container.selectedTab = .home
                router.replace(with: .home)
            }
        }
    }
}

// MARK: - 개별 단계 뷰 (Extension)
extension OnboardingView {

    // 1단계: 로그인 정보 (디자인 흐름상 가장 먼저 배치)
    private var loginInfoStep: some View {
        OnboardingLayout(
            title: "로그인에 사용할\n정보를 입력해주세요",
            buttonText: "다음으로",
            isButtonDisabled: !viewModel.isLoginInfoValid,
            showBackButton: true,
            backAction: { }, // 첫 화면이므로 이전 화면 이동 로직 필요 시 수정
            nextAction: { currentStep = .basicInfo }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("아이디")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                TextField("입력해주세요", text: $viewModel.loginId)
                    .padding().background(Color(._200)).cornerRadius(8)
                    .foregroundStyle(Color("customwhite"))

                Text("비밀번호")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                    .padding(.top, 10)
                SecureField("입력해주세요", text: $viewModel.password)
                    .padding().background(Color(._200)).cornerRadius(8)
                    .foregroundStyle(Color("customwhite"))

                if !viewModel.password.isEmpty && viewModel.password.count < 8 {
                    Text("비밀번호는 8자 이상이어야 합니다")
                        .font(.pretendardRegular(12))
                        .foregroundStyle(Color.red)
                        .padding(.top, 4)
                }

                Text("비밀번호 확인")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                    .padding(.top, 10)
                SecureField("입력해주세요", text: $viewModel.passwordConfirm)
                    .padding().background(Color(._200)).cornerRadius(8)
                    .foregroundStyle(Color("customwhite"))

                if !viewModel.passwordConfirm.isEmpty {
                    Text(viewModel.isPasswordMatching ? "비밀번호가 일치합니다" : "비밀번호가 일치하지 않습니다")
                        .font(.pretendardRegular(12))
                        .foregroundStyle(viewModel.isPasswordMatching ? Color("g_blue") : Color.red)
                        .padding(.top, 4)
                }
            }
        }
    }

    // 2단계: 기본 정보
    private var basicInfoStep: some View {
        OnboardingLayout(
            title: "반가워요!\n기본 정보를 입력해주세요",
            buttonText: "다음으로",
            isButtonDisabled: !viewModel.isBasicInfoValid,
            showBackButton: true,
            backAction: { currentStep = .loginInfo },
            nextAction: { currentStep = .profile }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                Text("이름")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                TextField("입력해주세요", text: $viewModel.name)
                    .padding().background(Color(._200)).cornerRadius(8)
                    .foregroundStyle(Color("customwhite"))

                Text("성별")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                    .padding(.top, 20)

                HStack(spacing: 12) {
                    genderButton(title: "남", value: "MALE")
                    genderButton(title: "여", value: "FEMALE")
                }

                Text("나이")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
                    .padding(.top, 20)

#if os(iOS)
                TextField(text: $viewModel.age, prompt: Text("입력해주세요")) {}
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(._200))
                    .cornerRadius(8)
                    .foregroundStyle(Color("customwhite"))
#else
                TextField(text: $viewModel.age, prompt: Text("입력해주세요")) {}
                    .padding()
                    .background(Color(._200))
                    .cornerRadius(8)
                    .foregroundStyle(Color("customwhite"))
#endif

                if !viewModel.age.isEmpty,
                   !(14...100).contains(Int(viewModel.age) ?? -1) {
                    Text("나이는 14세부터 100세 사이로 입력해주세요")
                        .font(.pretendardRegular(12))
                        .foregroundStyle(Color.red)
                }
            }
        }
    }

    // 3단계: 프로필 설정
    private var profileStep: some View {
        OnboardingLayout(
            title: "사용하실 프로필을\n설정해주세요",
            buttonText: "다음으로",
            isButtonDisabled: false,
            showBackButton: true,
            backAction: { currentStep = .basicInfo },
            nextAction: { currentStep = .sportsTalent }
        ) {
            VStack(spacing: 40) {
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color(._300))
                        .frame(width: 120, height: 120)
                        .overlay {
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .padding(35)
                                .foregroundColor(Color(._400))
                        }

                    Button(action: {
                        // 프로필 이미지 선택 로직
                    }, label: {
                        Circle()
                            .fill(Color(._400))
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: "camera")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color("customwhite"))
                            }
                    })
                    .offset(x: -5, y: -5)
                }
                .padding(.top, 20)

                Text("\(viewModel.name) 님의 프로필 사진을 등록해주세요.")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color("customwhite"))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // 4단계: 운동 재능
    private var sportsTalentStep: some View {
        OnboardingLayout(
            title: "내가 가진 운동 재능을\n알려주세요!",
            buttonText: "완료하기",
            isButtonDisabled: viewModel.sportId == nil || viewModel.level.isEmpty || viewModel.regionId == nil,
            showBackButton: true,
            backAction: { currentStep = .profile },
            nextAction: { currentStep = .welcome }
        ) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 35) {

                    // 1. 잘하는 운동 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("잘하는 운동")
                            .font(.pretendardMedium(16))
                            .foregroundStyle(Color("customwhite"))

                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 10) {
                                ForEach(["농구", "축구", "테니스", "배드민턴", "탁구"], id: \.self) { sport in
                                    sportTag(title: sport, id: 1) // 실제 서버 API의 종목 ID로 매핑 필요
                                }
                            }
                            HStack(spacing: 10) {
                                ForEach(["수영", "헬스", "클라이밍", "러닝"], id: \.self) { sport in
                                    sportTag(title: sport, id: 2) // 실제 서버 API의 종목 ID로 매핑 필요
                                }
                            }
                        }
                    }

                    // 2. 숙련도 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("숙련도")
                            .font(.pretendardMedium(16))
                            .foregroundStyle(Color("customwhite"))

                        VStack(spacing: 10) {
                            proficiencyCard(badge: "고인물", description: "실전 노하우와 기술까지 알려드릴 수 있어요", value: "ADVANCED")
                            proficiencyCard(badge: "지역 대표", description: "기본기를 넘어 응용까지 알려드릴 수 있어요", value: "INTERMEDIATE")
                            proficiencyCard(badge: "워밍업", description: "기본 동작과 규칙을 알려드릴 수 있어요", value: "BEGINNER")
                        }
                    }

                    // 3. 활동 지역 섹션
                    VStack(alignment: .leading, spacing: 16) {
                        Text("활동 지역")
                            .font(.pretendardMedium(16))
                            .foregroundStyle(Color("customwhite"))

                        Button(action: {
                            isRegionSheetPresented = true
                        }, label: {
                            HStack {
                                Text(selectedRegionName.isEmpty ? "선택해주세요" : selectedRegionName)
                                    .foregroundStyle(selectedRegionName.isEmpty ? Color(._400) : Color("customwhite"))
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(Color(._400))
                            }
                            .padding()
                            .background(Color(._200))
                            .cornerRadius(8)
                        })
                    }
                }
                .padding(.bottom, 20)
            }
            .sheet(isPresented: $isRegionSheetPresented) {
                NavigationStack {
                    List(Array(seoulDistricts.enumerated()), id: \.element) { index, district in
                        Button(action: {
                            selectedRegionName = district
                            viewModel.regionId = index + 1 // 실제 서버 API의 지역 ID로 매핑 필요
                            isRegionSheetPresented = false
                        }, label: {
                            HStack {
                                Text(district)
                                    .foregroundStyle(Color("customwhite"))
                                Spacer()
                                if selectedRegionName == district {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color("g_blue"))
                                }
                            }
                        })
                        .listRowBackground(Color(._100))
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color(._100))
                    .navigationTitle("활동 지역 선택")
                    .toolbar {
                        ToolbarItem() {
                            Button("닫기") { isRegionSheetPresented = false }
                        }
                    }
                }
                .preferredColorScheme(.dark)
            }
        }
    }

    // 5단계: 완료 화면
    private var welcomeStep: some View {
        VStack {
            Spacer()

            Text("\(viewModel.name.isEmpty ? "사용자" : viewModel.name) 님, 함께 운동을 교류할\n메이트를 찾아볼까요?")
                .font(.pretendardBold(24))
                .foregroundStyle(Color("customwhite"))
                .multilineTextAlignment(.center)
                .lineSpacing(6)

            Spacer()

            MainBigButton(
                text: "시작하기",
                isDisabled: viewModel.isLoading,
                action: {
                    viewModel.submitSignup()
                }
            )
        }
        .padding(.horizontal, 20)
        .background(Color(._100).ignoresSafeArea())
    }

    // MARK: - Sub Views

    /// 성별 선택 버튼
    private func genderButton(title: String, value: String) -> some View {
        let isSelected = (viewModel.gender == value)
        return Button(action: {
            viewModel.gender = value
        }) {
            Text(title)
                .font(.pretendardMedium(16))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(._200))
                .foregroundStyle(
                    isSelected ?
                    AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) :
                    AnyShapeStyle(Color(._500))
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color.clear),
                            lineWidth: 1
                        )
                )
        }
    }

    /// 운동 종목 태그 뷰
    private func sportTag(title: String, id: Int) -> some View {
        let isSelected = (selectedSportName == title)
        return Button(action: {
            selectedSportName = title
            viewModel.sportId = id
        }) {
            Text(title)
                .font(.pretendardMedium(14))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(._200))
                .foregroundStyle(
                    isSelected ?
                    AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) :
                    AnyShapeStyle(Color(._500))
                )
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isSelected ? AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color.clear),
                            lineWidth: 1
                        )
                )
        }
    }

    /// 숙련도 선택 카드 뷰
    private func proficiencyCard(badge: String, description: String, value: String) -> some View {
        let isSelected = (viewModel.level == value)
        return Button(action: {
            viewModel.level = value
        }) {
            HStack(spacing: 12) {
                Text(badge)
                    .font(.pretendardMedium(14))
                    .foregroundStyle(isSelected ? Color("customblack") : Color(._500))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        isSelected ? AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color(._300))
                    )
                    .cornerRadius(4)

                Text(description)
                    .font(.pretendardRegular(14))
                    .foregroundStyle(
                        isSelected ?
                        AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) :
                        AnyShapeStyle(Color(._500))
                    )
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding()
            .background(Color(._200))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? AnyShapeStyle(LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)) : AnyShapeStyle(Color.clear),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - 프리뷰
#Preview {
    OnboardingView()
        .environment(NavigationRouter())
        .environmentObject(DIContainer())
}
