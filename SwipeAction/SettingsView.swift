//
//  SettingsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/2/24.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @EnvironmentObject var userAuth: Authentication
    @State var showSignOut = false
    @State var showDefaultSheet = false
    @State var showProfileSheet = false
    
    var body: some View {
        
        ZStack {
            Color("Background-grey")
            VStack {
                Button {
                    showProfileSheet = true
                } label: {
                    Text("Profile")
                }
                .buttonStyle(PlainTextButtonStyle())
                .padding(.top)
                Button {
                    showDefaultSheet = true
                } label: {
                    Text("Default List")
                }
                .buttonStyle(PlainTextButtonStyle())
                Button("Sign Out") {
                    showSignOut = true
                }
                .buttonStyle(PlainTextButtonStyle())
                .disabled(!Auth.auth().userIsLoggedIn)
                .alert("Sign Out?", isPresented: $showSignOut) {
                    Button("Cancel", role: .cancel) { /* showSignOut = false */ }
                    Button("Sign Out", role: .destructive) {
                        do {
                            try Auth.auth().signOut()
                        } catch let error {
                            debugPrint("Error signing out: \(error)")
                        }
                    }
                } message: {
                    Text("Are you sure you want to sign out of your account?")
                }
                Spacer()
            }
            .padding([.leading, .trailing])
            .fullScreenCover(isPresented: $showDefaultSheet) {
                ListItemsView(key: "defaultItems", title: "Default Items", showShare: false)
            }
            .fullScreenCover(isPresented: $showProfileSheet) {
                ProfileView()
            }
        }
    }
    
}

#Preview {
    SettingsView()
}
