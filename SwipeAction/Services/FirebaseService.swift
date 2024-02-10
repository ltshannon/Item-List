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
    var sharedWith: [String]?
    var currentItems: [String]?
    var defaultItems: [String]?
}

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    @AppStorage("profile-url") var profileURL: String = ""
    @Published var users: [UserInformation] = []
    @Published var sharingUsers: [UserInformation] = []
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
    
    func getSharedUsers() async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let querySnapshot = try await database.collection("users").whereField("sharedWith", arrayContains: currentUid).getDocuments()
         
            DispatchQueue.main.async {
                var items: [UserInformation] = []
                for document in querySnapshot.documents {
                    do {
                        let user = try document.data(as: UserInformation.self)
                        items.append(user)
                    }
                    catch {
                        debugPrint("🧨", "getSharedUsers error: \(error.localizedDescription)")
                    }
                }

                self.sharingUsers = items
            }
        } catch {
            debugPrint("🧨", "getSharedUsers: \(error)")
        }

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
    
    func restoreDefault(items: [String]) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let value = [
                    ListItemType.currentItems.rawValue : items
                    ]
        do {
            try await database.collection("users").document(currentUid).updateData(value)
        } catch {
            debugPrint(String.boom, "setDefaultToCurrent: \(error)")
        }
    }
    
    func deleteItem(userId: String, key: ListItemType, item: String) async {
        
        let value = [
                    key.rawValue : FieldValue.arrayRemove([item])
                    ]
        do {
            try await database.collection("users").document(userId).updateData(value)
        } catch {
            debugPrint(String.boom, "deleteItem: \(error)")
        }
    }
    
    func updateItems(userId: String, key: ListItemType, item: String) async {
        
        let value = [
                    key.rawValue : FieldValue.arrayUnion([item])
                    ]
        do {
            try await database.collection("users").document(userId).updateData(value)
        } catch {
            debugPrint(String.boom, "updateItems: \(error)")
        }
    }
    
    func updateShared(id: String) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let value = [
                        "sharedWith" : FieldValue.arrayUnion([id])
                    ]
        do {
            try await database.collection("users").document(currentUid).updateData(value)
        } catch {
            debugPrint(String.boom, "updateShared: \(error)")
        }
    }
    
    func deleteShared(id: String) async {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        let value = [
                        "sharedWith" : FieldValue.arrayRemove([id])
                    ]
        do {
            try await database.collection("users").document(currentUid).updateData(value)
        } catch {
            debugPrint(String.boom, "deleteShared: \(error)")
        }
    }
    
}
