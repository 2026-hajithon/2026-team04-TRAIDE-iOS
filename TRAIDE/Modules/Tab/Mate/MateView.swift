import SwiftUI

struct MateView: View {
    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel = MateViewModel()
    @State private var showRequests = false

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var displayedMates: [Mate] {
        var result = viewModel.mates
        for mate in container.requestedMates where !result.contains(where: { $0.id == mate.id }) {
            result.append(mate)
        }
        return result
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    mateSection
                }
            }
            .refreshable { await viewModel.load() }
            .background(MatePalette.background.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showRequests) {
                MateRequestListView(viewModel: viewModel)
            }
            .task { await viewModel.load() }
            .overlay {
                if viewModel.isLoading && displayedMates.isEmpty {
                    ProgressView().tint(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Text("메이트")
                .font(.pretendardSemiBold(24))
                .foregroundStyle(MatePalette.primaryText)
            Spacer()
            Image("homeProfile")
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(Circle().stroke(MatePalette.avatarBorder, lineWidth: 1))
        }
        .frame(height: 52)
        .padding(.horizontal, 20)
    }

    private var mateSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("내 메이트 \(displayedMates.count)")
                    .font(.pretendardSemiBold(16))
                    .foregroundStyle(MatePalette.sectionText)
                Spacer()
                Button("요청(\(viewModel.requests.count))") { showRequests = true }
                    .font(.pretendardMedium(14))
                    .foregroundStyle(MatePalette.mutedText)
            }

            if displayedMates.isEmpty, !viewModel.isLoading {
                Text(viewModel.errorMessage ?? "아직 등록된 메이트가 없어요.")
                    .font(.pretendardRegular(14))
                    .foregroundStyle(MatePalette.mutedText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(displayedMates) { mate in
                        Button {
                            container.navigationRouter.push(.otherProfile(ProfileDetail(mate: mate)))
                        } label: {
                            MateGridCard(mate: mate)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

}

private struct MateGridCard: View {
    let mate: Mate

    var body: some View {
        VStack(spacing: 8) {
            MateAvatar(imageURL: mate.imageURL, size: 60, borderWidth: 2.5)
            VStack(spacing: 6) {
                Text(mate.nickname)
                    .font(.pretendardMedium(16))
                    .foregroundStyle(MatePalette.primaryText)
                    .lineLimit(1)
                SportTags(primary: mate.teachingSport, secondary: mate.learningSport)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(MatePalette.card, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct MateRequestCard: View {
    let request: MateRequest
    let onAccept: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                MateAvatar(imageURL: request.mate.imageURL, size: 84, borderWidth: 2)
                VStack(alignment: .leading, spacing: 6) {
                    SportTags(primary: request.mate.teachingSport, secondary: request.mate.learningSport)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(request.mate.nickname)
                            .font(.pretendardSemiBold(20))
                            .foregroundStyle(MatePalette.primaryText)
                        Text(profileDescription)
                            .font(.pretendardRegular(14))
                            .foregroundStyle(MatePalette.detailText)
                    }
                }
                Spacer(minLength: 0)
            }
            HStack(spacing: 8) {
                Button("거절하기", action: onReject)
                    .buttonStyle(RequestButtonStyle(fill: MatePalette.rejectButton, foreground: MatePalette.primaryText))
                Button("수락하기", action: onAccept)
                    .buttonStyle(RequestButtonStyle(fill: MatePalette.acceptButton, foreground: MatePalette.buttonText))
            }
        }
        .padding(20)
        .background(MatePalette.card, in: RoundedRectangle(cornerRadius: 20))
    }

    private var profileDescription: String {
        let age = request.mate.age.map { "\($0)세" }
        return ["여", age, request.mate.district].compactMap { $0 }.joined(separator: " / ")
    }
}

private struct MateRequestListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: MateViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if viewModel.requests.isEmpty {
                    Text("새 메이트 요청이 없어요.")
                        .font(.pretendardRegular(14))
                        .foregroundStyle(MatePalette.mutedText)
                        .padding(.top, 120)
                } else {
                    ForEach(viewModel.requests) { request in
                        MateRequestCard(
                            request: request,
                            onAccept: { Task { await viewModel.accept(request) } },
                            onReject: { Task { await viewModel.reject(request) } }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
        .background(MatePalette.background.ignoresSafeArea())
        .navigationTitle("요청(\(viewModel.requests.count))")
        .navigationBarTitleDisplayMode(.inline)
        .customBackButton(action: dismiss.callAsFunction)
        .toolbarBackground(MatePalette.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

private struct SportTags: View {
    let primary: String
    let secondary: String

    var body: some View {
        HStack(spacing: 6) {
            if !primary.isEmpty { SportTag(text: primary) }
            if !secondary.isEmpty { SportTag(text: secondary) }
        }
    }
}

private struct SportTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.pretendardMedium(12))
            .foregroundStyle(MatePalette.tagGradient)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(MatePalette.tagBackground, in: Capsule())
            .lineLimit(1)
    }
}

private struct MateAvatar: View {
    let imageURL: String?
    let size: CGFloat
    let borderWidth: CGFloat

    var body: some View {
        RemoteProfileImage(imageUrl: imageURL, size: size)
            .overlay(Circle().stroke(MatePalette.avatarBorder, lineWidth: borderWidth))
    }
}

private struct RequestButtonStyle: ButtonStyle {
    let fill: Color
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pretendardSemiBold(14))
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(fill.opacity(configuration.isPressed ? 0.75 : 1), in: RoundedRectangle(cornerRadius: 12))
    }
}

private enum MatePalette {
    static let background = Color(red: 30 / 255, green: 32 / 255, blue: 37 / 255)
    static let card = Color(red: 49 / 255, green: 54 / 255, blue: 62 / 255)
    static let primaryText = Color(red: 253 / 255, green: 253 / 255, blue: 253 / 255)
    static let sectionText = Color(red: 175 / 255, green: 183 / 255, blue: 194 / 255)
    static let mutedText = Color(red: 121 / 255, green: 130 / 255, blue: 143 / 255)
    static let detailText = Color(red: 141 / 255, green: 151 / 255, blue: 163 / 255)
    static let avatarBorder = Color(red: 90 / 255, green: 99 / 255, blue: 112 / 255)
    static let rejectButton = Color(red: 90 / 255, green: 99 / 255, blue: 112 / 255)
    static let acceptButton = Color(red: 240 / 255, green: 242 / 255, blue: 245 / 255)
    static let buttonText = Color(red: 19 / 255, green: 20 / 255, blue: 23 / 255)
    static let tagGradient = LinearGradient(
        colors: [Color(red: 131 / 255, green: 208 / 255, blue: 255 / 255), Color(red: 155 / 255, green: 244 / 255, blue: 238 / 255)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let tagBackground = LinearGradient(
        colors: [Color(red: 131 / 255, green: 208 / 255, blue: 255 / 255).opacity(0.1), Color(red: 155 / 255, green: 244 / 255, blue: 238 / 255).opacity(0.1)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

#Preview {
    MateView()
        .environmentObject(DIContainer())
}
