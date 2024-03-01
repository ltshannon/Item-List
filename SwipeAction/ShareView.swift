//
//  ShareView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/6/24.
//

import SwiftUI

struct ShareView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    @State var showingSheet = false
    @State var showingAlert = false
    @State var showingAlert2 = false
    @State var users: [NameList] = []
    @State var addUserId = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(users, id: \.id) { item in
                        Text(item.name)
                    }
                    .onMove(perform: move)
                    .onDelete { indexSet in
                        let index = indexSet[indexSet.startIndex]
                        let id = users[index].id
                        users.remove(atOffsets: indexSet)
                        deleteSharedUser(id: id)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("You are sharing to these users:").font(.headline)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                users = []
                for item in firebaseService.users {
                    if let id = item.id, id == userAuth.firebaseUserId, let users = item.sharedWith {
                        let names = users.compactMap { getUserName(id: $0) }
                        self.users = names
                    }
                }
            }
            .onReceive(firebaseService.$users) { items in
                if let user = userAuth.user {
                    for item in items {
                        if user.uid == item.id {
                            var array: [NameList] = []
                            if let sharedTo = item.sharedWith, sharedTo.count > 0 {
                                let _ = sharedTo.map { sharedItem in
                                    let sharedUser = findUserFrom(id: sharedItem)
                                    let nameList = NameList(id: sharedItem, name: sharedUser?.displayName ?? "n/a")
                                    array.append(nameList)
                                    return true
                                }
                                DispatchQueue.main.async {
                                    self.users = array
                                }
                                return
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showingSheet, onDismiss: didDismiss) {
                ConnectionView(addUserId: $addUserId)
            }
            .alert("Name already in list", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            }
            .alert("Can not share to yourself", isPresented: $showingAlert2) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    func findUserFrom(id: String) -> UserInformation? {
        for item in firebaseService.users {
            if let userId = item.id, userId == id {
                return item
            }
        }
        return nil
    }
    
    func getUserName(id: String) -> NameList? {
        if let item = findUserFrom(id: id), let userId = item.id, let name = item.displayName {
            return NameList(id: userId, name: name)
        }
        return nil
    }
    
    func move(from source: IndexSet, to destination: Int) {
        users.move(fromOffsets: source, toOffset: destination)
    }
    
    func didDismiss() {
        if let user = userAuth.user, user.uid == addUserId {
            showingAlert2 = true
            return
        }
        if let _ = users.firstIndex(where: { $0.id == addUserId }) {
            showingAlert = true
            return
        }
        if let nameList = getUserName(id: addUserId) {
            users.append(nameList)
            Task {
                await firebaseService.updateShared(id: addUserId)
            }
        }
    }
    
    func deleteSharedUser(id: String) {
        Task {
            await firebaseService.deleteShared(id: id)
        }
    }
}

#Preview {
    ShareView()
}
