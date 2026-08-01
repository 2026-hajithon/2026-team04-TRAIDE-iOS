//
//  ProfileView.swift
//  TRAIDE
//

import Observation
import SwiftUI

struct ProfileView: View {
    @Environment(NavigationRouter.self) private var router
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack(spacing: 0) {
            navigationBar

            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    profileSummary
                    reviewsSection
                    logsSection
                    bottomActionSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .background(Color(._100).ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

private extension ProfileView {
    var navigationBar: some View {
        HStack {
            Button(action: router.pop) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color(.customwhite))
                    .frame(width: 24, height: 24)
            }
            .frame(width: 44, alignment: .leading)

            Spacer()

            Text("내 프로필")
                .font(.pretendardSemiBold(18))
                .foregroundStyle(Color(.customwhite))

            Spacer()

            Color.clear.frame(width: 44, height: 24)
        }
        .frame(height: 52)
        .padding(.horizontal, 16)
    }

    var profileSummary: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Circle()
                    .fill(Color(._200))
                    .frame(width: 120, height: 120)

                Text(viewModel.nickname)
                    .font(.pretendardSemiBold(26))
                    .foregroundStyle(Color(.customwhite))

                profileTags
            }

            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Button("프로필 수정하기") {
                        print("프로필 수정하기 탭")
                    }
                    .buttonStyle(ProfileActionButtonStyle(background: Color(.customwhite)))

                    Button("채팅하기") {
                        router.push(.chat(roomId: "test_room_id"))
                    }
                    .buttonStyle(ProfileActionButtonStyle(background: Color("g_mint")))
                }

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
                Text("메이트들과의 운동 열기")
                    .font(.pretendardRegular(14))
                    .foregroundStyle(Color(._500))

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text("\(viewModel.temperatureBpm)")
                        .font(.pretendardBold(24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1, green: 0.51, blue: 0.48), Color(red: 1, green: 0.94, blue: 0.90)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
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
                print("로그아웃 탭")
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
    let review: MateReview

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(review.author)
                .font(.pretendardMedium(12))
                .foregroundStyle(Color(._600))

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

#Preview {
    ProfileView()
        .environment(NavigationRouter())
}
