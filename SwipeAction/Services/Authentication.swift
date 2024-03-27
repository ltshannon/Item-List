//
//  Authentication.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/3/24.
//

import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import UserNotifications

//Class to manage firebase configuration and backend authentication
@MainActor
class Authentication: ObservableObject {
    static let shared = Authentication()
    private var handler: AuthStateDidChangeListenerHandle? = nil
    @Published var user: User?
    @Published var state: AuthState = .loggedOut
    @Published var isGuestUser = false
    @Published var firebaseUserId = ""
    @Published var email: String = ""
    @Published var fcmToken: String = ""
    
    enum AuthState: String {
        case waiting = "waiting"
        case accountSetup = "accountSetup"
        case loggedIn = "loggedIn"
        case loggedOut = "loggedOut"
    }
    
    init() {
        
        handler = Auth.auth().addStateDidChangeListener { auth, user in
            debugPrint("🛎️", "Authentication Firebase auth state changed, logged in: \(auth.userIsLoggedIn)")
            
            self.user = user
            
            DispatchQueue.main.async {
                self.isGuestUser = false
                if let isAnonymous = user?.isAnonymous {
                    self.isGuestUser = isAnonymous
                }
            }
            
            //case where user loggedin but waiting account setup
            guard self.state != .accountSetup else {
                return
            }
            
            //case where no user auth, likely first run
            guard let currentUser = auth.currentUser else {
                self.state = .loggedOut
                return
            }
            
            var email = ""
            if let temp = currentUser.email {
                email = temp
            }
            
            self.state = auth.userIsLoggedIn ? .loggedIn : .loggedOut
            
            switch self.state {
            case .waiting, .accountSetup:
                break
                
            case .loggedIn:
                DispatchQueue.main.async {
                    self.firebaseUserId = user?.uid ?? ""
                    self.email = email
                }
            case .loggedOut:
                break
            }
        }
        
        NotificationCenter.default.addObserver(forName: Notification.Name("FCMToken"), object: nil, queue: nil) { notification in
            let newToken = notification.userInfo?["token"] as? String ?? ""
            Task {
                await MainActor.run {
                    self.fcmToken = newToken
                }
            }
        }
    }
    
    func setUser(user: User) {
        self.user = user
    }
}

extension Auth {
    var userIsLoggedIn: Bool {
        currentUser != nil
    }
}
