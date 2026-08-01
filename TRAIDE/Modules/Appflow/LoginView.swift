//
//  LoginView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

struct LoginView: View {
    @State private var id: String = ""
    @State private var password: String = ""
    
    // ⭐️ 1. 텍스트 필드의 포커스 상태를 추적하기 위한 열거형 및 상태 변수 추가
    enum Field {
        case id, password
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // MARK: - 로고 영역
            Text("TRAIDE")
                .font(.system(size: 56, weight: .heavy, design: .default))
                .foregroundStyle(Color(.customwhite))
                .padding(.bottom, 60)
            
            // MARK: - 입력 폼 영역
            VStack(spacing: 16) {
                // 아이디 입력
                TextField("아이디", text: $id)
                    .focused($focusedField, equals: .id) // ⭐️ 2. 포커스 바인딩
                    .padding()
                    .background(Color(._200))
                    .cornerRadius(8)
                    .foregroundStyle(Color(.customwhite))
                
                // 비밀번호 입력
                SecureField("비밀번호", text: $password)
                    .focused($focusedField, equals: .password) // ⭐️ 3. 포커스 바인딩
                    .padding()
                    .background(Color(._200))
                    .cornerRadius(8)
                    .foregroundStyle(Color(.customwhite))
            }
            .padding(.bottom, 30)
            
            // MARK: - 로그인 버튼
            MainBigButton(
                text: "로그인",
                isDisabled: id.isEmpty || password.isEmpty,
                action: {
                    focusedField = nil // 버튼을 눌렀을 때도 키보드 내리기
                    print("로그인 시도: \(id)")
                    // TODO: 로그인 처리 로직 추가
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
                    print("회원가입 화면(온보딩)으로 이동")
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
        // ⭐️ 4. 빈 배경을 탭했을 때 포커스를 해제(nil)하여 키보드를 내립니다.
        .onTapGesture {
            focusedField = nil
        }
    }
}

// MARK: - 프리뷰
#Preview {
    LoginView()
}
