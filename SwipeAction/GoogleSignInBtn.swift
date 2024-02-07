//
//  GoogleSiginBtn.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/4/24.
//

import SwiftUI

struct GoogleSignInBtn: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                ZStack{
                    Circle()
                        .foregroundColor(.white)
                        .shadow(color: .gray, radius: 4, x: 0, y: 2)
                    
                    Image("google")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                        .mask(
                            Circle()
                        )
                }
                .frame(width: 80, height: 80)
                Text("Login with Google")
            }
            
        }
    }
}

#Preview {
    GoogleSignInBtn(action: {})
}
