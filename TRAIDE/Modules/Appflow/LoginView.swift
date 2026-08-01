//
//  LoginView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI
import Combine

struct LoginView: View {
    @Environment(NavigationRouter.self) private var router
    @EnvironmentObject private var container: DIContainer
    @StateObject private var viewModel = LoginViewModel()

    enum Field {
        case id, password
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - 로고 영역
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 159.32617, height: 56)
                .tint(.customwhite)



            // MARK: - 입력 폼 영역
            VStack(spacing: 16) {
                // 아이디 입력
                TextField("아이디", text: $viewModel.loginId)
                    .focused($focusedField, equals: .id)
                    .padding()
                    .background(Color(._200))
                    .cornerRadius(8)
                    .foregroundStyle(Color(._500))

                // 비밀번호 입력
                SecureField("비밀번호", text: $viewModel.password)
                    .focused($focusedField, equals: .password)
                    .padding()
                    .background(Color(._200))
                    .cornerRadius(8)
                    .foregroundStyle(Color(.customwhite))
            }
            .padding(.bottom, 30)

            // MARK: - 로그인 버튼
            MainBigButton(
                text: "로그인",
                isDisabled: viewModel.loginId.isEmpty || viewModel.password.isEmpty || viewModel.isLoading,
                action: {
                    focusedField = nil

                    viewModel.login()
                }
            )
            .padding(.bottom, 24)

            // MARK: - 하단 링크 영역
            HStack(spacing: 16) {
                Text("아이디 찾기")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color(._500))

                Text("|")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color(._500))

                Text("비밀번호 찾기")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color(._500))

                Text("|")
                    .font(.pretendardMedium(14))
                    .foregroundStyle(Color(._500))

                Button(action: {
                    router.push(.onboarding)
                }) {
                    Text("회원가입")
                        .font(.pretendardMedium(14))
                        .foregroundStyle(Color(._500))
                }
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
        .background(Color(._100).ignoresSafeArea())
        .onTapGesture {
            focusedField = nil
        }
        // MARK: - 로딩 오버레이
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
            }
        }
        // MARK: - 에러 알림창
        .alert("알림", isPresented: $viewModel.showError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
        // MARK: - 로그인 성공 처리
        .onChange(of: viewModel.isLoginSuccessful) { _, isSuccess in
            if isSuccess {
                container.completeAuthentication()
            }
        }
    }
}

// MARK: - 프리뷰
#Preview {
    LoginView()
        .environment(NavigationRouter())
        .environmentObject(DIContainer())
}
