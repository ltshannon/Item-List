//
//  ContentView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/1/24.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var userAuth: Authentication
    @State private var showSignIn: Bool = false
    
    var body: some View {
        VStack {
            ListItemsView(key: "currentItems", title: "Items")
        }
        .onAppear {
            debugPrint("😍", "ContentView onAppear userAtuh.state: \(userAuth.state.rawValue)")
            if userAuth.state == .loggedOut {
                showSignIn = true
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
