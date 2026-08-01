//
//  LoginView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//


import SwiftUI

/// 로그인 (스펙 2-1장)
/// TODO:
/// - 로그인 API 호출 연결
/// - 아이디 찾기 / 비밀번호 찾기 / 회원가입 네비게이션 연결
/// - 회원가입 5단계 플로우 진입점 연결
struct LoginView: View {
    @State private var userId: String = ""
    @State private var password: String = ""

    var body: some View {
        ZStack {
            Color._100
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 100)

                Image(.logo)
                    .resizable()
                    .scaledToFit()

                Spacer()
                    .frame(height: 48)

                VStack(spacing: 20) {
                    TextField("아이디", text: $userId)
                TextField("비밀번호", text: $password)
                }

                Spacer()
                    .frame(height: 24)

                MainBigButton(text: "로그인"){
                    // TODO: 로그인 API 호출
                }

                Spacer()
                    .frame(height: 16)

                bottomLinks

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }

    private var bottomLinks: some View {
        HStack(spacing: 12) {
            linkButton("아이디 찾기")
                .font(.pretendardBold(12))
                
            divider
                .foregroundStyle(._800)
            linkButton("비밀번호 찾기")
            divider
            linkButton("회원가입")
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color._400)
            .frame(width: 1, height: 12)
    }

    private func linkButton(_ title: String) -> some View {
        Button {
            // TODO: 화면 이동 연결
        } label: {
            Text(title)
                .font(.pretendardBold(12))
                .foregroundStyle(._600)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .preferredColorScheme(.dark)
}



