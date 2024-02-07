//
//  ShareView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/6/24.
//

import SwiftUI

struct NameList: Identifiable {
    var id: String
    var name: String
}

struct ShareView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    @State var showingSheet = false
    @State var showingAlert = false
    @State var users: [NameList] = []
    @State var addUserId = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("You are sharing to these users:")
                List {
                    ForEach(users, id: \.id) { item in
                        Text(item.name)
                    }
                    .onMove(perform: move)
                    .onDelete { indexSet in
                        users.remove(atOffsets: indexSet)
                    }
                }
            }
            .navigationTitle("Share Your Items")
            .toolbar {
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
                    if let id = item.id, id == userAuth.firebaseUserId, let users = item.sharedTo {
                        let names = users.map { getUserName(id: $0) }
                        self.users = names
                    }
                }
            }
            .fullScreenCover(isPresented: $showingSheet, onDismiss: didDismiss) {
                ConnectionView(addUserId: $addUserId)
            }
            .alert("Name already in list", isPresented: $showingAlert) {
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
    
    func getUserName(id: String) -> NameList {
        if let item = findUserFrom(id: id), let userId = item.id, let name = item.displayName {
            return NameList(id: userId, name: name)
        }
        return NameList(id: UUID().uuidString, name: "n/a")
    }
    
    func move(from source: IndexSet, to destination: Int) {
        users.move(fromOffsets: source, toOffset: destination)
    }
    
    func didDismiss() {
        if let _ = users.firstIndex(where: { $0.id == addUserId }) {
            showingAlert = true
            return
        }
        let nameList = getUserName(id: addUserId)
        users.append(nameList)
//        if let user = findUserFrom(id: addUserId) {
//
//        }
//        if let index = users.firstIndex(where: { $0.id == addUserId }) {
//            users.remove(at: index)
//        }
    }
}

#Preview {
    ShareView()
}
