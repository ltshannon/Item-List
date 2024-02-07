//
//  FirebaseService.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/5/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFunctions
import FirebaseFirestoreSwift

let database = Firestore.firestore()

struct UserInformation: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var displayName: String?
    var email: String?
    var fcm: String?
    var sharedTo: [String]?
    var currentItems: [String]?
    var defaultItems: [String]?
}

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    @Published var users: [UserInformation] = []
    @AppStorage("profile-url") var profileURL: String = ""
    private var userListener: ListenerRegistration?
    
    func getUsers() {
        
        let listener = database.collection("users").addSnapshotListener { querySnapshot, error in

            guard let documents = querySnapshot?.documents else {
                debugPrint("🧨", "Users no documents")
                return
            }
            
            var items: [UserInformation] = []
            for document in documents {
                do {
                    let user = try document.data(as: UserInformation.self)
                    items.append(user)
                }
                catch {
                    debugPrint("🧨", "\(error.localizedDescription)")
                }
            }
            DispatchQueue.main.async {
                self.users = items
            }

        }
        userListener = listener
    }
    
    func updateAddFCMToUser(token: String) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let values = [
                        "fcm" : token,
                     ]
        do {
            try await database.collection("users").document(currentUid).updateData(values)
        } catch {
            debugPrint("🧨", "updateAddFCMToUser: \(error)")
        }
        
    }
    
    func updateAddUserProfileImage(url: String) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let value = [
                        "profileImage" : url
                    ]
        do {
            try await database.collection("users").document(currentUid).updateData(value)
        } catch {
            debugPrint(String.boom, "updateAddUserProfileImage: \(error)")
        }
    }
    
    func findUserFrom(id: String) -> UserInformation? {
        for item in users {
            if let userId = item.id, userId == id {
                return item
            }
        }
        return nil
    }
}
