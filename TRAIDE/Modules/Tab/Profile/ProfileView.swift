//
//  ProfileView.swift
//  TRAIDE
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isShowingEditor = false
    @State private var isShowingLogoutConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.userProfile == nil {
                ProgressView("프로필을 불러오는 중이에요")
                    .tint(Color("g_blue"))
                    .foregroundStyle(Color(.customwhite))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.showError && viewModel.userProfile == nil {
                ContentUnavailableView {
                    Label(viewModel.errorMessage ?? "프로필을 불러오지 못했어요", systemImage: "wifi.exclamationmark")
                } actions: {
                    Button("다시 시도") {
                        Task { await viewModel.loadMyProfile() }
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 40) {
                        profileSummary
                        reviewsSection
                        bottomActionSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(Color(._100).ignoresSafeArea())
        .navigationTitle("내 프로필")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color(._100), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task { await viewModel.loadMyProfile() }
        .sheet(isPresented: $isShowingEditor) {
            if let profile = viewModel.userProfile {
                ProfileEditSheet(
                    profile: profile,
                    sports: viewModel.sports,
                    regions: viewModel.regions
                ) { request in
                    await viewModel.updateProfile(request: request)
                }
            }
        }
        .confirmationDialog(
            "로그아웃하시겠어요?",
            isPresented: $isShowingLogoutConfirmation,
            titleVisibility: .visible
        ) {
            Button("로그아웃", role: .destructive) {
                container.logout()
            }
            Button("취소", role: .cancel) { }
        }
    }
}

private extension ProfileView {
    var profileSummary: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                RemoteProfileImage(imageUrl: viewModel.userProfile?.imageUrl, size: 120)
                    .overlay(Circle().stroke(Color(._300), lineWidth: 2))

                Text(viewModel.nickname)
                    .font(.pretendardSemiBold(26))
                    .foregroundStyle(Color(.customwhite))

                profileTags
            }

            VStack(spacing: 8) {
                Button("프로필 수정하기") {
                    isShowingEditor = true
                }
                .buttonStyle(ProfileActionButtonStyle(background: Color(.customwhite)))

                statsSection
                temperatureSection
            }
            .padding(.top, 0)
        }
    }

    var profileTags: some View {
        HStack(spacing: 5) {
            Text(viewModel.mainSport)
                .foregroundStyle(Color(.customblack))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(
                        colors: [Color("g_blue"), Color("g_mint")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))

            ProfileTag(text: viewModel.proficiency)
            ProfileTag(text: viewModel.ageAndGender)

            Label(viewModel.location, systemImage: "mappin")
                .labelStyle(.titleAndIcon)
                .foregroundStyle(Color(.customwhite))
                .imageScale(.small)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(._200))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .font(.pretendardMedium(14))
    }

    var statsSection: some View {
        HStack(spacing: 44) {
            statistic(title: "운동 메이트", value: "\(viewModel.mateCount)명")
            statistic(title: "총 만남 횟수", value: "\(viewModel.meetCount)회")
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(Color(._200), in: RoundedRectangle(cornerRadius: 20))
    }

    func statistic(title: String, value: String) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.pretendardRegular(14))
                .foregroundStyle(Color(._500))

            Text(value)
                .font(.pretendardSemiBold(24))
                .foregroundStyle(Color(.customwhite))
        }
        .frame(maxWidth: .infinity)
    }

    var temperatureSection: some View {
        HStack(spacing: 12) {
            Image(.fire)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 0) {
                Text("메이트 평점")
                    .font(.pretendardRegular(14))
                    .foregroundStyle(Color(._500))

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(viewModel.averageRating.formatted(.number.precision(.fractionLength(1))))
                        .font(.pretendardBold(24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.51, blue: 0.48), Color(red: 1, green: 0.94, blue: 0.90)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    Text("/ 5.0 · 후기 \(viewModel.reviewCount)개")
                        .font(.pretendardSemiBold(16))
                        .foregroundStyle(Color(.customwhite))
                }
            }

            Spacer()
        }
        .padding(.horizontal, 21)
        .padding(.vertical, 20)
        .background(Color(._200), in: RoundedRectangle(cornerRadius: 20))
    }

    var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "메이트들의 한마디")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.reviews) { review in
                        ReviewCard(review: review)
                    }
                }
            }
            .scrollClipDisabled()
        }
    }

    var logsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "운동 로그")

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible())],
                spacing: 8
            ) {
                ForEach(0..<4, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(._200))
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }

    var bottomActionSection: some View {
        HStack(spacing: 10) {
            Button("로그아웃") {
                isShowingLogoutConfirmation = true
            }
            Text("|")
            Button("탈퇴하기") {
                print("탈퇴하기 탭")
            }
        }
        .font(.pretendardMedium(12))
        .foregroundStyle(Color(._500))
    }
}

private struct ProfileActionButtonStyle: ButtonStyle {
    let background: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pretendardSemiBold(16))
            .foregroundStyle(Color(.customblack))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                background.opacity(configuration.isPressed ? 0.75 : 1),
                in: RoundedRectangle(cornerRadius: 16)
            )
    }
}

private struct ProfileTag: View {
    let text: String

    var body: some View {
        Text(text)
            .foregroundStyle(Color(.customwhite))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(._200))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ReviewCard: View {
    let review: ProfileReview

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                RemoteProfileImage(imageUrl: review.writer.imageUrl, size: 24)
                Text(review.writer.name)
                    .font(.pretendardMedium(12))
                    .foregroundStyle(Color(._600))
                Spacer()
                Label("\(review.rating)", systemImage: "star.fill")
                    .font(.pretendardMedium(12))
                    .foregroundStyle(Color("g_mint"))
            }

            Text(review.content)
                .font(.pretendardRegular(14))
                .foregroundStyle(Color(.customwhite))
                .lineSpacing(2)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(width: 290, height: 98, alignment: .topLeading)
        .background(Color(._200), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.pretendardSemiBold(20))
                .foregroundStyle(Color(.customwhite))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(.customwhite))
                .frame(width: 24, height: 24)
        }
        .frame(height: 27)
    }
}

private struct ProfileEditSheet: View {
    @Environment(\.dismiss) private var dismiss

    let sports: [Sport]
    let regions: [Region]
    let onSave: (UpdateUserProfile) async -> Bool

    @State private var name: String
    @State private var age: Int
    @State private var gender: ViewProfileRequest.Gender
    @State private var sportId: Int
    @State private var level: ViewProfileRequest.Level
    @State private var regionId: Int
    @State private var isSaving = false

    init(
        profile: ViewProfileRequest,
        sports: [Sport],
        regions: [Region],
        onSave: @escaping (UpdateUserProfile) async -> Bool
    ) {
        self.sports = sports
        self.regions = regions
        self.onSave = onSave
        _name = State(initialValue: profile.name)
        _age = State(initialValue: profile.age)
        _gender = State(initialValue: profile.gender)
        _sportId = State(initialValue: profile.sport.id)
        _level = State(initialValue: profile.level)
        _regionId = State(initialValue: profile.region.id)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("이름", text: $name)
                        .textInputAutocapitalization(.never)
                    Stepper("나이: \(age)세", value: $age, in: 14...100)
                    Picker("성별", selection: $gender) {
                        Text("남성").tag(ViewProfileRequest.Gender.male)
                        Text("여성").tag(ViewProfileRequest.Gender.female)
                    }
                }

                Section("운동 정보") {
                    Picker("운동 종목", selection: $sportId) {
                        ForEach(sports, id: \.id) { sport in
                            Text(sport.name).tag(sport.id)
                        }
                    }
                    Picker("레벨", selection: $level) {
                        Text("워밍업").tag(ViewProfileRequest.Level.beginner)
                        Text("동네 에이스").tag(ViewProfileRequest.Level.intermediate)
                        Text("고인물").tag(ViewProfileRequest.Level.advanced)
                    }
                    Picker("지역", selection: $regionId) {
                        ForEach(regions, id: \.id) { region in
                            Text(region.name).tag(region.id)
                        }
                    }
                }
            }
            .navigationTitle("프로필 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        Task {
                            isSaving = true
                            let request = UpdateUserProfile(
                                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                                age: age,
                                gender: gender,
                                sportId: sportId,
                                level: level,
                                regionId: regionId
                            )
                            if await onSave(request) {
                                dismiss()
                            }
                            isSaving = false
                        }
                    }
                    .disabled(isSaving || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .interactiveDismissDisabled(isSaving)
        }
    }
}

#Preview {
    ProfileView()
        .environment(NavigationRouter())
        .environmentObject(DIContainer())
}
