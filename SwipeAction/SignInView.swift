//
//  SignInView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/3/24.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct SignInView: View {
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await GoogleSignInService.shared.signInGoogle()
                        debugPrint("🦁", "user signed in with goolge")
                    } catch {
                        debugPrint("", "GoogleSignInService return error: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SignInView()
}
