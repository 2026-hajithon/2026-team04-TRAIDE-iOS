//
//  MainButtonStyle.swift
//  TRAIDE
//
//  Created by 김지우 on 8/1/26.
//

import SwiftUI

struct MainButtonStyle: ButtonStyle {
    let isDisabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(
                isDisabled
                ? Color._700
                : (configuration.isPressed ? Color.customwhite : Color.customblack)
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        isDisabled
                                        ? AnyShapeStyle(Color._300)
                                        : AnyShapeStyle(
                                            LinearGradient(
                                                colors: configuration.isPressed
                                                ? [Color.gBlue.opacity(0.7), Color.gMint.opacity(0.7)]
                                                    : [Color.gBlue, Color.gMint],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    )
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
