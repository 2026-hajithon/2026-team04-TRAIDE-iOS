//
//  BackButtonModifier.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

// BackButtonModifier.swift
import SwiftUI

struct BackButtonModifier: ViewModifier {
    @Environment(NavigationRouter.self) var router
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem() {
                    Button(action: {
                        router.pop()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color("customwhite")) // 컬러 에셋 적용
                    }
                }
            }
    }
}

extension View {
    func customBackButton() -> some View {
        self.modifier(BackButtonModifier())
    }
}
