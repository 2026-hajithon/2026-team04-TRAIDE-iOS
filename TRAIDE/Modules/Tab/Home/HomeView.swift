//
//  HomeView.swift
//  TRAIDE
//

import SwiftUI

struct HomeView: View {
    @Environment(NavigationRouter.self) private var router
    private let sports = ["테니스", "배드민턴", "농구", "축구", "헬스", "러닝", "탁구", "클라이밍", "수영"]

    @StateObject private var viewModel: HomeViewModel
    @State private var selectedSports: Set<String> = []
    @State private var dismissedProfileIDs: Set<Int> = []
    @State private var cardOffset: CGFloat = 0
    @State private var isDismissingCard = false

    init(viewModel: HomeViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? HomeViewModel())
    }

    private var availableProfiles: [ViewProfileRequest] {
        viewModel.profiles.filter { profile in
            !dismissedProfileIDs.contains(profile.id)
                && (selectedSports.isEmpty || selectedSports.contains(profile.sport.name))
        }
    }

    var body: some View {
        ZStack {
            Color(._100).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    sportFilters.padding(.top, 6)
                    profileDeck.padding(.top, 16)

                    if !availableProfiles.isEmpty {
                        actionButtons.padding(.top, 24)
                    }
                }
                .padding(.bottom, 28)
            }
            .scrollDisabled(cardOffset != 0)
        }
        .task { await viewModel.loadProfiles() }
        .onChange(of: selectedSports) { _, _ in resetCardPosition() }
    }
}

private extension HomeView {
    var header: some View {
        HStack {
            Button(action: {}) {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.circle")
                    Text("서울 전체").font(.pretendardMedium(14))
                    Image(systemName: "chevron.down").font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(Color(.customwhite))
                .padding(.horizontal, 10)
                .frame(height: 38)
                .background(Color(._200), in: RoundedRectangle(cornerRadius: 12))
            }

            Spacer()

            Image("homeProfile")
                .resizable()
                .scaledToFill()
                .frame(width: 34, height: 34)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color(._300), lineWidth: 1))
        }
        .padding(.horizontal, 20)
        .frame(height: 52)
    }

    var sportFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                if !selectedSports.isEmpty {
                    Button {
                        selectedSports.removeAll()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(Color("g_blue"))
                            .frame(width: 40, height: 38)
                            .background(Color(._200), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .accessibilityLabel("종목 필터 초기화")
                }

                ForEach(sports, id: \.self) { sport in
                    Button { toggleSport(sport) } label: {
                        Text(sport)
                            .font(.pretendardMedium(14))
                            .foregroundStyle(selectedSports.contains(sport) ? Color("g_blue") : Color(.customwhite))
                            .padding(.horizontal, 12)
                            .frame(height: 38)
                            .background(Color(._200), in: RoundedRectangle(cornerRadius: 12))
                            .overlay {
                                if selectedSports.contains(sport) {
                                    RoundedRectangle(cornerRadius: 12).stroke(Color("g_blue"), lineWidth: 1)
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    @ViewBuilder
    var profileDeck: some View {
        if viewModel.isLoading && viewModel.profiles.isEmpty {
            ProgressView("프로필을 불러오는 중이에요")
                .tint(Color("g_blue"))
                .foregroundStyle(Color(._700))
                .frame(maxWidth: .infinity, minHeight: 415)
        } else if let errorMessage = viewModel.errorMessage, viewModel.profiles.isEmpty {
            unavailableState(
                title: errorMessage,
                systemImage: "wifi.exclamationmark",
                buttonTitle: "다시 시도"
            ) {
                Task { await viewModel.loadProfiles(force: true) }
            }
        } else if availableProfiles.isEmpty {
            unavailableState(
                title: "새로운 프로필이 없어요",
                systemImage: "person.2.slash",
                buttonTitle: "처음부터 보기"
            ) {
                dismissedProfileIDs.removeAll()
            }
        } else {
            ZStack {
                if availableProfiles.count > 1 {
                    profileCard(availableProfiles[1])
                        .scaleEffect(0.96)
                        .offset(y: 8)
                        .allowsHitTesting(false)
                }

                profileCard(availableProfiles[0])
                    .id(availableProfiles[0].id)
                    .offset(x: cardOffset)
                    .rotationEffect(.degrees(Double(cardOffset / 28)))
                    .opacity(max(0.25, 1 + cardOffset / 360))
                    .contentShape(RoundedRectangle(cornerRadius: 24))
                    .onTapGesture {
                        guard abs(cardOffset) < 8 else { return }
                        router.push(.otherProfile(ProfileDetail(profile: availableProfiles[0])))
                    }
                    .gesture(cardDragGesture)
                    .accessibilityHint("왼쪽으로 쓸어 넘기면 다음 프로필을 볼 수 있습니다")
            }
            .padding(.horizontal, 20)
        }
    }

    func profileCard(_ profile: ViewProfileRequest) -> some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                HStack(spacing: 4) {
                    Image("fire").resizable().scaledToFit().frame(width: 20, height: 20)
                    Text("\(profile.appointmentCount)회 활동")
                        .font(.pretendardBold(16))
                        .foregroundStyle(Color(red: 1, green: 0.55, blue: 0.52))
                }
                .padding(.horizontal, 10)
                .frame(height: 34)
                .background(Color(red: 1, green: 0.55, blue: 0.52).opacity(0.20), in: Capsule())

                VStack(spacing: 8) {
                    RemoteProfileImage(imageUrl: profile.imageUrl, size: 100)
                        .overlay(Circle().stroke(Color(._300), lineWidth: 4))

                    Text(profile.name)
                        .font(.pretendardSemiBold(28))
                        .foregroundStyle(Color(.customwhite))
                        .lineLimit(1)

                    HStack(spacing: 5) {
                        infoChip(icon: "mappin.circle", text: profile.region.name)
                        infoChip(text: "\(profile.age)세 / \(genderLabel(profile.gender))")
                    }
                }
            }

            VStack(spacing: 8) {
                Text(profile.sport.name)
                    .font(.pretendardSemiBold(20))
                    .foregroundStyle(Color("g_blue"))
                Text(levelLabel(profile.level))
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color(._200))
                    .padding(.horizontal, 12)
                    .frame(height: 34)
                    .background(Color("g_mint"), in: Capsule())
            }
            .frame(maxWidth: .infinity)
            .frame(height: 106)
            .background(
                LinearGradient(
                    colors: [Color("g_blue").opacity(0.11), Color("g_mint").opacity(0.11)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 20)
            )
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        .background(Color(._200), in: RoundedRectangle(cornerRadius: 24))
    }

    func infoChip(icon: String? = nil, text: String) -> some View {
        HStack(spacing: 4) {
            if let icon {
                Image(systemName: icon)
            }
            Text(text).font(.pretendardMedium(14)).lineLimit(1)
        }
        .foregroundStyle(Color(._800))
        .padding(.horizontal, 10)
        .frame(height: 34)
        .background(Color(._300), in: RoundedRectangle(cornerRadius: 8))
    }

    func genderLabel(_ gender: ViewProfileRequest.Gender) -> String {
        switch gender {
        case .male: "남"
        case .female: "여"
        }
    }

    func levelLabel(_ level: ViewProfileRequest.Level) -> String {
        switch level {
        case .beginner: "입문"
        case .intermediate: "중급"
        case .advanced: "고급"
        }
    }

    func unavailableState(
        title: String,
        systemImage: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: systemImage)
        } actions: {
            Button(buttonTitle, action: action).buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, minHeight: 415)
    }

    var cardDragGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard !isDismissingCard else { return }
                cardOffset = min(0, value.translation.width)
            }
            .onEnded { value in
                guard !isDismissingCard else { return }
                if value.translation.width < -90 || value.predictedEndTranslation.width < -160 {
                    dismissCurrentProfile()
                } else {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                        cardOffset = 0
                    }
                }
            }
    }

    var actionButtons: some View {
        HStack(spacing: 12) {
            actionButton(
                title: "넘기기",
                systemImage: "envelope.badge",
                foreground: Color(.customwhite),
                background: AnyShapeStyle(Color(._300)),
                action: dismissCurrentProfile
            )
            actionButton(
                title: "메이트 신청",
                systemImage: "paperplane.fill",
                foreground: Color(._200),
                background: AnyShapeStyle(
                    LinearGradient(
                        colors: [Color("g_blue"), Color("g_mint")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                ),
                action: { /* TODO: 메이트 신청 API 연결 */ }
            )
        }
        .padding(.horizontal, 70)
    }

    func actionButton(
        title: String,
        systemImage: String,
        foreground: Color,
        background: AnyShapeStyle,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemImage).font(.system(size: 38, weight: .light)).frame(height: 44)
                Text(title).font(.pretendardMedium(14))
            }
            .foregroundStyle(foreground)
            .frame(width: 120, height: 116)
            .background(background, in: RoundedRectangle(cornerRadius: 20))
        }
        .disabled(isDismissingCard)
    }

    func toggleSport(_ sport: String) {
        if selectedSports.contains(sport) {
            selectedSports.remove(sport)
        } else {
            selectedSports.insert(sport)
        }
    }

    func dismissCurrentProfile() {
        guard let currentProfile = availableProfiles.first, !isDismissingCard else { return }
        isDismissingCard = true

        withAnimation(.easeIn(duration: 0.22)) {
            cardOffset = -500
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            dismissedProfileIDs.insert(currentProfile.id)
            resetCardPosition()
        }
    }

    func resetCardPosition() {
        cardOffset = 0
        isDismissingCard = false
    }
}

#Preview {
    HomeView().preferredColorScheme(.dark)
}
