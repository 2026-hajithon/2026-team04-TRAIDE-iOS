//
//  RegisterView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

struct RegisterView: View {
    var body: some View {
        ZStack{
            
            Color._100
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            
            Text("반가워요!\n기본정보를 입력해주세요")
                .foregroundStyle(.customwhite)
                .font(.pretendardBold(24))

        }
    }
}

#Preview {
    RegisterView()
}
