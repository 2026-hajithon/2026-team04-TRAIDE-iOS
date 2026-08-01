//
//  ChatBubble.swift
//  TRAIDE
//
//  Created by 김지우 on 8/2/26.
//

import SwiftUI

// MARK: - 말풍선 컴포넌트
struct ChatBubble: View {
    let text: String
    let time: String
    let isMe: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isMe {
                Text(time)
                    .font(.pretendardRegular(11))
                    .foregroundStyle(Color(._400))
                    .padding(.bottom, 2)
                
                Text(text)
                    .font(.pretendardRegular(15))
                    .foregroundStyle(Color("customblack"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
            } else {
                Text(text)
                    .font(.pretendardRegular(15))
                    .foregroundStyle(Color("customwhite"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color(._200))
                    .cornerRadius(16)
                
                Text(time)
                    .font(.pretendardRegular(11))
                    .foregroundStyle(Color(._400))
                    .padding(.bottom, 2)
            }
        }
    }
}
