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
    let isHidden: Bool
    let action: (() -> Void)?

    init(isHidden: Bool = false, action: (() -> Void)? = nil) {
        self.isHidden = isHidden
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if !isHidden {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            if let action {
                                action()
                            } else {
                                router.pop()
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundStyle(Color("customwhite")) // 컬러 에셋 적용
                        }
                    }
                }
            }
    }
}

extension View {
    func customBackButton(isHidden: Bool = false, action: (() -> Void)? = nil) -> some View {
        modifier(BackButtonModifier(isHidden: isHidden, action: action))
    }
}
