//
//  SplashView.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        
        ZStack{
            
            
            LinearGradient(colors: [Color("g_blue"), Color("g_mint")], startPoint: .leading, endPoint: .trailing)
                .ignoresSafeArea()
            
            VStack{
                Spacer(minLength: 320)
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal,115)
                
                
                
                
                Image(.splashbottom)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal,115)
                
                Spacer(minLength: 300)

            }
                
        }
        
    }
}

#Preview {
    SplashView()
}
