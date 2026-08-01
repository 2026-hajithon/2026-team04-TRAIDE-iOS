import PhotosUI
import SwiftUI

struct ProfileDetail: Hashable {
    enum Relationship: Hashable {
        case recommendation
        case mate
    }

    let id: String
    let name: String
    let imageURL: String?
    let sport: String
    let level: String
    let age: Int?
    let gender: String?
    let district: String
    let mateCount: Int
    let appointmentCount: Int
    let heatBPM: Int
    let chatRoomID: String?
    let relationship: Relationship

    var canLeaveRecord: Bool {
        relationship == .mate && appointmentCount > 0
    }

    init(profile: ViewProfileRequest) {
        id = String(profile.id)
        name = profile.name
        imageURL = profile.imageUrl
        sport = profile.sport.name
        level = Self.levelLabel(profile.level)
        age = profile.age
        gender = profile.gender == .male ? "남" : "여"
        district = profile.region.name
        mateCount = profile.friendCount
        appointmentCount = profile.appointmentCount
        heatBPM = max(0, min(100, Int((profile.averageRating * 20).rounded())))
        chatRoomID = nil
        relationship = .recommendation
    }

    init(mate: Mate) {
        id = mate.id
        name = mate.nickname
        imageURL = mate.imageURL
        sport = mate.teachingSport
        level = mate.learningSport
        age = mate.age
        gender = nil
        district = mate.district ?? ""
        mateCount = 0
        appointmentCount = mate.appointmentCount
        heatBPM = 80
        chatRoomID = mate.chatRoomID
        relationship = .mate
    }

    private static func levelLabel(_ level: ViewProfileRequest.Level) -> String {
        switch level {
        case .beginner: "입문"
        case .intermediate: "중급"
        case .advanced: "고인물"
        }
    }
}

struct OtherProfileView: View {
    @Environment(NavigationRouter.self) private var router
    @EnvironmentObject private var container: DIContainer
    let profile: ProfileDetail

    private var isRequestSent: Bool {
        container.isMateRequested(id: profile.id)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 40) {
                profileSummary
                reviewsSection

                if profile.relationship == .mate {
                    recordButton
                }

                activityLogSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 40)
        }
        .background(Color(._100).ignoresSafeArea())
        .navigationTitle("프로필")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .toolbar(.hidden, for: .tabBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color(._100), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            if profile.relationship == .mate {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("친구 끊기", role: .destructive) {
                            // TODO: 메이트 삭제 API가 추가되면 연결합니다.
                        }
                    } label: {
                        Image(systemName: "ellipsis.vertical")
                            .foregroundStyle(Color(.customwhite))
                    }
                }
            }
        }
    }
}

private extension OtherProfileView {
    var profileSummary: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                RemoteProfileImage(imageUrl: profile.imageURL, size: 120)
                    .overlay(Circle().stroke(Color(._300), lineWidth: 3))

                Text(profile.name)
                    .font(.pretendardSemiBold(26))
                    .foregroundStyle(Color(.customwhite))

                tags
            }

            VStack(spacing: 8) {
                if profile.relationship == .recommendation {
                    mateRequestButton
                } else {
                    MainBigButton(text: "채팅하기") {
                        let currentUserID = FirebaseSessionService.shared.currentUserId ?? ""
                        let directRoomID = [currentUserID, profile.id]
                            .filter { !$0.isEmpty }
                            .sorted()
                            .joined(separator: "_")
                        router.push(.chat(
                            roomId: profile.chatRoomID ?? "direct_\(directRoomID)",
                            participantId: profile.id,
                            participantName: profile.name
                        ))
                    }
                }
                statistics
                heatCard
            }
        }
    }

    var mateRequestButton: some View {
        Button {
            container.setMateRequest(profile.asMate, isRequested: !isRequestSent)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isRequestSent
                            ? AnyShapeStyle(Color(._200))
                            : AnyShapeStyle(ProfileFlowPalette.gradient)
                    )

                Text(isRequestSent ? "신청 취소" : "메이트 신청하기")
                    .font(.pretendardSemiBold(16))
                    .foregroundStyle(isRequestSent ? Color(.customwhite) : Color(.customblack))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isRequestSent ? "메이트 신청 취소" : "메이트 신청하기")
    }

    var tags: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 5) { profileTags }
            VStack(spacing: 6) {
                HStack(spacing: 5) { profileCoreTags }
                if !profile.district.isEmpty { locationTag }
            }
        }
        .font(.pretendardMedium(14))
    }

    @ViewBuilder var profileTags: some View {
        profileCoreTags
        if !profile.district.isEmpty { locationTag }
    }

    @ViewBuilder var profileCoreTags: some View {
        Text(profile.sport)
            .foregroundStyle(Color(.customblack))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(ProfileFlowPalette.gradient, in: RoundedRectangle(cornerRadius: 8))
        detailTag(profile.level)
        if let age = profile.age {
            detailTag(["\(age)세", profile.gender].compactMap { $0 }.joined(separator: " / "))
        }
    }

    var locationTag: some View {
        Label(profile.district, systemImage: "mappin")
            .foregroundStyle(Color(.customwhite))
            .imageScale(.small)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(._200), in: RoundedRectangle(cornerRadius: 8))
    }

    func detailTag(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(Color(.customwhite))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(._200), in: RoundedRectangle(cornerRadius: 8))
    }

    var statistics: some View {
        HStack(spacing: 44) {
            statistic(title: "운동 메이트", value: "\(profile.mateCount)명")
            statistic(title: "총 만남 횟수", value: "\(profile.appointmentCount)회")
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 30)
        .padding(.vertical, 20)
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

    var heatCard: some View {
        HStack(spacing: 12) {
            Image("fire")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            VStack(alignment: .leading, spacing: 0) {
                Text("메이트들과의 운동 열기")
                    .font(.pretendardRegular(14))
                    .foregroundStyle(Color(._500))
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(profile.heatBPM)")
                        .font(.pretendardBold(24))
                        .foregroundStyle(ProfileFlowPalette.heatGradient)
                    Text("Bpm")
                        .font(.pretendardSemiBold(24))
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
            ProfileSectionHeader(title: "메이트들의 한마디")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ProfileReviewCard(author: "슬로우러너", content: "\(profile.sport) 너무 잘하시구 잘 가르쳐주세요.. 최고!!! 처음 만났는데도 편하게 잘 이끌어주셨어요.")
                    ProfileReviewCard(author: "운동수집가", content: "설명도 재밌고 친절해서 운동하는 내내 즐거웠어요. 다음에도 같이 운동하고 싶어요!")
                }
            }
            .scrollClipDisabled()
        }
    }

    var recordButton: some View {
        Button {
            router.push(.record(profile))
        } label: {
            Text("함께한 기록 남기기")
                .font(.pretendardSemiBold(16))
                .foregroundStyle(profile.canLeaveRecord ? Color(.customblack) : Color(._500))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    profile.canLeaveRecord ? Color(._900) : Color(._200),
                    in: RoundedRectangle(cornerRadius: 16)
                )
        }
        .disabled(!profile.canLeaveRecord)
        .accessibilityHint(profile.canLeaveRecord ? "기록 보내기 화면으로 이동합니다" : "함께한 약속 기록이 있을 때 사용할 수 있습니다")
    }

    var activityLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProfileSectionHeader(title: "운동 로그")
            HStack(spacing: 8) {
                logImage("profileLogOne")
                logImage("profileLogTwo")
            }
        }
    }

    func logImage(_ name: String) -> some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private extension ProfileDetail {
    var asMate: Mate {
        Mate(
            id: id,
            nickname: name,
            teachingSport: sport,
            learningSport: level,
            age: age,
            district: district,
            imageURL: imageURL,
            appointmentCount: appointmentCount,
            chatRoomID: chatRoomID
        )
    }
}

struct ActivityRecordView: View {
    @Environment(NavigationRouter.self) private var router
    @EnvironmentObject private var container: DIContainer
    let profile: ProfileDetail

    @State private var score = 0
    @State private var note = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedPhotoData: Data?
    @State private var isSent = false

    var body: some View {
        Group {
            if isSent { sentView } else { formView }
        }
        .background(Color(._100).ignoresSafeArea())
        .toolbar(.hidden, for: .tabBar)
    }
}

private extension ActivityRecordView {
    var formView: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    VStack(spacing: 22) {
                        Text("\(profile.name) 님과의\n운동은 어떠셨나요?")
                            .font(.pretendardSemiBold(24))
                            .foregroundStyle(Color(.customwhite))
                            .multilineTextAlignment(.center)

                        VStack(spacing: 10) {
                            HStack(spacing: 4) {
                                ForEach(1...5, id: \.self) { value in
                                    Button { score = value } label: {
                                        Image("fire")
                                            .resizable()
                                            .scaledToFit()
                                            .saturation(value <= score ? 1 : 0)
                                            .opacity(value <= score ? 1 : 0.28)
                                            .frame(maxWidth: 60, maxHeight: 60)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("열기 \(value)점")
                                }
                            }
                            Text("보낸 열기는 나만 확인할 수 있어요")
                                .font(.pretendardSemiBold(14))
                                .foregroundStyle(Color(._500))
                        }
                    }

                    VStack(spacing: 16) {
                        TextEditor(text: $note)
                            .font(.pretendardMedium(16))
                            .foregroundStyle(Color(.customwhite))
                            .scrollContentBackground(.hidden)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .frame(height: 126)
                            .background(Color(._200), in: RoundedRectangle(cornerRadius: 16))
                            .overlay(alignment: .topLeading) {
                                if note.isEmpty {
                                    Text("함께한 소감을 한 마디 작성해주세요")
                                        .font(.pretendardMedium(16))
                                        .foregroundStyle(Color(._500))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 17)
                                        .allowsHitTesting(false)
                                }
                            }

                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            photoPickerLabel
                        }
                        .onChange(of: selectedPhoto) { _, item in
                            Task { selectedPhotoData = try? await item?.loadTransferable(type: Data.self) }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
            }

            MainBigButton(text: "완료하기", isDisabled: score == 0) {
                isSent = true
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .navigationTitle("기록 남기기")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton()
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(Color(._100), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    @ViewBuilder var photoPickerLabel: some View {
        if let selectedPhotoData, let image = UIImage(data: selectedPhotoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 186)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        } else {
            VStack(spacing: 4) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color(._300))
                Text("인증샷 첨부(선택)")
                    .font(.pretendardMedium(16))
                    .foregroundStyle(Color(._600))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 186)
            .background(Color(._200), in: RoundedRectangle(cornerRadius: 16))
        }
    }

    var sentView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                Text("\(profile.name) 님에게")
                HStack(spacing: 0) {
                    Text("소중한 기록")
                        .foregroundStyle(ProfileFlowPalette.gradient)
                    Text("이 전송되었어요!")
                }
            }
            .font(.pretendardSemiBold(24))
            .foregroundStyle(Color(.customwhite))
            .multilineTextAlignment(.center)

            Image("recordSent")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 350)

            Spacer()

            MainBigButton(text: "홈으로 가기") {
                container.selectedTab = .home
                router.reset()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct ProfileSectionHeader: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.pretendardSemiBold(20))
                .foregroundStyle(Color(.customwhite))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(._500))
        }
        .frame(height: 27)
    }
}

private struct ProfileReviewCard: View {
    let author: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(author)
                .font(.pretendardMedium(12))
                .foregroundStyle(Color(._600))
            Text(content)
                .font(.pretendardRegular(14))
                .foregroundStyle(Color(.customwhite))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(width: 290, height: 92, alignment: .topLeading)
        .background(Color(._200), in: RoundedRectangle(cornerRadius: 16))
    }
}

private enum ProfileFlowPalette {
    static let gradient = LinearGradient(
        colors: [Color("g_blue"), Color("g_mint")],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let heatGradient = LinearGradient(
        colors: [Color(red: 254 / 255, green: 129 / 255, blue: 122 / 255), Color(red: 254 / 255, green: 239 / 255, blue: 229 / 255)],
        startPoint: .top,
        endPoint: .bottom
    )
}

#Preview("메이트 프로필") {
    NavigationStack {
        OtherProfileView(profile: ProfileDetail(mate: Mate(
            id: "1",
            nickname: "테니스의왕자",
            teachingSport: "테니스",
            learningSport: "고인물",
            age: 27,
            district: "용산구",
            imageURL: nil,
            appointmentCount: 82,
            chatRoomID: "preview"
        )))
    }
    .environment(NavigationRouter())
    .preferredColorScheme(.dark)
}
