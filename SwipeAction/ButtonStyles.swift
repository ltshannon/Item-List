//
//  ButtonStyles.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/5/24.
//

import SwiftUI

struct PlainTextButtonStyle: ButtonStyle {
    var backgroundColor: Color = Color("SettingBackground")
    var foregroundColor: Color = Color("SettingsForeground")
    var verticalPadding: CGFloat = 10.0

    func makeBody(configuration: Self.Configuration) -> some View {
            HStack {
                configuration.label
                    .font(.buttonText)
                    .padding(.leading)
                Spacer()
            }
            .foregroundColor(foregroundColor)
            .frame(minWidth: 0,
                   maxWidth: .infinity,
                   minHeight: 44.0)
            .padding([.top, .bottom], verticalPadding)
            .background(
                backgroundColor
                    .cornerRadius(14)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .padding(.trailing, 4.0) //This compensates for shadow width
    }
}
