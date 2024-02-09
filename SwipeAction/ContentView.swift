//
//  ContentView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/1/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userAuth: Authentication
    @EnvironmentObject var firebaseService: FirebaseService
    @State private var showSignIn: Bool = false
    @State var userId = ""
    
    var body: some View {
        TabView {
            ListItemsView(key: ListItemType.currentItems, title: "Items")
                .tabItem {
                    Label("My List", systemImage: "list.dash")
                }
                .tag(1)
            SharedListView()
                .tabItem {
                    Label("Shared Lists", systemImage: "list.dash")
                }
                .tag(2)
            
//            ListItemsView(key: "defaultItems", title: "Default Items", showShare: false)
//                .tabItem {
//                    Label("Default List", systemImage: "list.dash")
//                }
//                .tag(3)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .onAppear {
            firebaseService.getUsers()
        }
        .onReceive(userAuth.$state) { state in
            debugPrint("😍", "ContentView onReceive userAtuh.state: \(state)")
            if state == .loggedOut {
                showSignIn = true
            }
            if state == .loggedIn {
                showSignIn = false
            }
        }
        .onReceive(userAuth.$fcmToken) { token in
            if token.isNotEmpty {
                Task {
                    await firebaseService.updateAddFCMToUser(token: userAuth.fcmToken)
                }
            }
        }
        .fullScreenCover(isPresented: $showSignIn) {
            SignInView()
        }
    }

}

#Preview {
    ContentView()
}
