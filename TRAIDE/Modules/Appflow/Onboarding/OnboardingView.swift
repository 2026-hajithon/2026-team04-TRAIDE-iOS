import SwiftUI
import UIKit

struct OnboardingView: View {
    @Environment(NavigationRouter.self) private var router
    @EnvironmentObject private var container: DIContainer
    @State private var currentStep: OnboardingStep = .loginInfo
    @StateObject private var viewModel = SignupViewModel()
    @FocusState private var focusedField: AccountField?

    private enum AccountField { case id, password, passwordConfirm, name, age }

    private let sports = [
        (1, "농구"), (2, "축구"), (3, "테니스"), (4, "배드민턴"), (5, "탁구"),
        (6, "수영"), (7, "헬스"), (8, "클라이밍"), (9, "러닝")
    ]
    private let districts = [
        "강남구", "강동구", "강북구", "강서구", "관악구", "광진구", "구로구", "금천구", "노원구",
        "도봉구", "동대문구", "동작구", "마포구", "서대문구", "서초구", "성동구", "성북구", "송파구",
        "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"
    ]

    var body: some View {
        ZStack {
            Color._100.ignoresSafeArea()
            switch currentStep {
            case .loginInfo: loginInfoView
            case .requiredInfo: requiredInfoView
            case .sportsTalent: sportsTalentView
            case .welcome: welcomeView
            }
        }
        .customBackButton(isHidden: currentStep == .sportsTalent || currentStep == .welcome) {
            if currentStep == .loginInfo {
                router.pop()
            } else if currentStep == .requiredInfo {
                currentStep = .loginInfo
            }
        }
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color._100, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar(currentStep == .sportsTalent || currentStep == .welcome ? .hidden : .visible, for: .navigationBar)
        .animation(.easeInOut(duration: 0.22), value: currentStep)
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView().tint(.white)
            }
        }
        .alert("알림", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "오류가 발생했습니다.")
        }
        .onChange(of: viewModel.isSignupSuccessful) { _, succeeded in
            if succeeded { currentStep = .welcome }
        }
    }

    private var loginInfoView: some View {
        onboardingPage {
            VStack(alignment: .leading, spacing: 32) {
                title("로그인에 사용할\n정보를 입력해주세요")
                VStack(spacing: 24) {
                    accountField(label: "아이디", placeholder: "입력해주세요", text: $viewModel.loginId, field: .id)
                    accountField(label: "비밀번호", placeholder: "입력해주세요", text: $viewModel.password, field: .password, secure: true)
                    VStack(alignment: .leading, spacing: 8) {
                        accountField(label: "비밀번호 확인", placeholder: "입력해주세요", text: $viewModel.passwordConfirm, field: .passwordConfirm, secure: true)
                        if !viewModel.passwordConfirm.isEmpty {
                            Text(viewModel.isPasswordMatching ? "비밀번호가 일치합니다" : "비밀번호가 일치하지 않습니다")
                                .font(.pretendardMedium(12))
                                .foregroundStyle(viewModel.isPasswordMatching ? gradient : errorGradient)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        } bottom: {
            MainBigButton(text: "다음으로", isDisabled: !viewModel.isLoginInfoValid) {
                focusedField = nil
                currentStep = .requiredInfo
            }
        }
    }

    private var requiredInfoView: some View {
        onboardingPage {
            VStack(alignment: .leading, spacing: 32) {
                title("반가워요!\n기본 정보를 입력해주세요")

                VStack(spacing: 24) {
                    basicInfoField(
                        label: "이름",
                        text: $viewModel.name,
                        field: .name
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("성별")
                        HStack(spacing: 6) {
                            genderButton(title: "남", value: "MALE")
                            genderButton(title: "여", value: "FEMALE")
                        }
                    }

                    basicInfoField(
                        label: "나이",
                        text: $viewModel.age,
                        field: .age,
                        keyboardType: .numberPad
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        } bottom: {
            MainBigButton(text: "다음으로", isDisabled: !viewModel.isBasicInfoValid) {
                focusedField = nil
                currentStep = .sportsTalent
            }
        }
    }

    private var sportsTalentView: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 36) {
                    title("내가 가진 운동 재능을\n알려주세요!")

                    VStack(alignment: .leading, spacing: 12) {
                        sectionLabel("잘하는 운동")
                        FlexibleTagLayout(spacing: 6) {
                            ForEach(sports, id: \.0) { sport in
                                sportTag(id: sport.0, name: sport.1)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("숙련도")
                        proficiencyCard("고인물", "실전 노하우와 기술까지 알려드릴 수 있어요", "ADVANCED")
                        proficiencyCard("지역대표", "기본기를 넘어 응용까지 알려드릴 수 있어요", "INTERMEDIATE")
                        proficiencyCard("워밍업", "기본 동작과 규칙을 알려드릴 수 있어요", "BEGINNER")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        sectionLabel("활동 지역")
                        regionPicker
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 31)
                .padding(.bottom, 28)
            }

            MainBigButton(
                text: "완료하기",
                isDisabled: viewModel.sportId == nil || viewModel.level.isEmpty || viewModel.regionId == nil || viewModel.isLoading
            ) {
                viewModel.submitSignup()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
    }

    private var welcomeView: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 142)
            VStack(spacing: 0) {
                Text("\(viewModel.displayName) 님, 함께 운동을 교류할")
                    .foregroundStyle(Color.customwhite)
                HStack(spacing: 0) {
                    Text("메이트").foregroundStyle(gradient)
                    Text("를 찾아볼까요?").foregroundStyle(Color.customwhite)
                }
            }
            .font(.pretendardSemiBold(24))

            Image("onboardingMate")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 365, maxHeight: 307)
                .padding(.top, 48)

            Spacer(minLength: 20)
            MainBigButton(text: "시작하기") { container.completeAuthentication() }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
    }

    private func onboardingPage<Content: View, Bottom: View>(
        @ViewBuilder content: () -> Content,
        @ViewBuilder bottom: () -> Bottom
    ) -> some View {
        VStack(spacing: 0) {
            content().frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            bottom().padding(.horizontal, 20).padding(.top, 8).padding(.bottom, 12)
        }
    }

    private func title(_ text: String) -> some View {
        Text(text)
            .font(.pretendardSemiBold(24))
            .foregroundStyle(Color.customwhite)
            .lineSpacing(6)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.pretendardSemiBold(16)).foregroundStyle(Color.customwhite)
    }

    private func accountField(label: String, placeholder: String, text: Binding<String>, field: AccountField, secure: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.pretendardSemiBold(16)).foregroundStyle(Color.customwhite)
            Group {
                if secure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .focused($focusedField, equals: field)
            .font(.pretendardMedium(16))
            .foregroundStyle(Color.customwhite)
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color._200, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func basicInfoField(
        label: String,
        text: Binding<String>,
        field: AccountField,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionLabel(label)
            TextField("입력해주세요", text: text)
                .focused($focusedField, equals: field)
                .keyboardType(keyboardType)
                .font(.pretendardMedium(16))
                .foregroundStyle(Color.customwhite)
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color._200, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func genderButton(title: String, value: String) -> some View {
        let selected = viewModel.gender == value
        return Button {
            viewModel.gender = value
        } label: {
            Text(title)
                .font(.pretendardMedium(16))
                .foregroundStyle(selected ? Color.customblack : Color.customwhite)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(selected ? gradient : AnyShapeStyle(Color._200), in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func sportTag(id: Int, name: String) -> some View {
        let selected = viewModel.sportId == id
        return Button {
            viewModel.sportId = id
        } label: {
            Text(name)
                .font(.pretendardMedium(14))
                .foregroundStyle(selected ? gradient : AnyShapeStyle(Color.customwhite))
                .padding(.horizontal, 16)
                .frame(height: 40)
                .background(Color._200, in: RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selected ? gradient : AnyShapeStyle(Color.clear), lineWidth: 1)
                }
        }
    }

    private func proficiencyCard(_ badge: String, _ description: String, _ value: String) -> some View {
        let selected = viewModel.level == value
        return Button { viewModel.level = value } label: {
            HStack(spacing: 10) {
                Text(badge)
                    .font(.pretendardMedium(14))
                    .foregroundStyle(selected ? Color.customblack : Color.customwhite)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(selected ? gradient : AnyShapeStyle(Color._400), in: RoundedRectangle(cornerRadius: 6))
                Text(description)
                    .font(.pretendardMedium(14))
                    .foregroundStyle(selected ? gradient : AnyShapeStyle(Color.customwhite))
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 12)
            .frame(height: 54)
            .background(Color._200, in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? gradient : AnyShapeStyle(Color.clear), lineWidth: 1)
            }
        }
    }

    private var regionPicker: some View {
        Menu {
            ForEach(Array(districts.enumerated()), id: \.element) { index, district in
                Button(district) {
                    viewModel.regionId = index + 1
                }
            }
        } label: {
            HStack {
                Text(selectedDistrict ?? "선택해주세요")
                    .font(.pretendardMedium(16))
                    .foregroundStyle(selectedDistrict == nil ? Color._500 : Color.customwhite)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color._500)
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .background(Color._200, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private var selectedDistrict: String? {
        guard let id = viewModel.regionId, districts.indices.contains(id - 1) else { return nil }
        return districts[id - 1]
    }

    private var gradient: AnyShapeStyle {
        AnyShapeStyle(LinearGradient(colors: [.gBlue, .gMint], startPoint: .leading, endPoint: .trailing))
    }

    private var errorGradient: AnyShapeStyle {
        AnyShapeStyle(LinearGradient(colors: [Color(red: 1, green: 0.46, blue: 0.52), Color(red: 1, green: 0.55, blue: 0.49)], startPoint: .leading, endPoint: .trailing))
    }
}

private struct FlexibleTagLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > width {
                x = 0; y += rowHeight + spacing; rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX; y += rowHeight + spacing; rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(NavigationRouter())
        .environmentObject(DIContainer())
}
