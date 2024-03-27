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
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    @State var errorMessage = ""
    @State var showError = false
    
    var body: some View {
        VStack {
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await GoogleSignInService.shared.signInGoogle()
                        debugPrint("🦁", "user signed in with goolge")
                        firebaseService.getUsers()
                    } catch {
                        debugPrint("", "GoogleSignInService return error: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
            }
            Button {
                Task {
                    do {
                        let result = try await Auth.auth().signInAnonymously()
                        userAuth.setUser(user: result.user)
                        firebaseService.getUsers()
                    }
                    catch {
                        debugPrint("🧨", "signInAnonymously error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.errorMessage = error.localizedDescription
                            self.showError = true
                        }
                    }
                }
            } label: {
                Text("Login Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(2)
            }
        }
        .padding([.leading, .trailing], 20)
        .alert("Error", isPresented: $showError) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text("Error: \(errorMessage)")
        }
    }
}

#Preview {
    SignInView()
}
