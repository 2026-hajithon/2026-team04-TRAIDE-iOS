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
            
            Color._100
                .ignoresSafeArea()
                .edgesIgnoringSafeArea(.all)
            
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal,20)
                
        }
        
    }
}

#Preview {
    SplashView()
}
