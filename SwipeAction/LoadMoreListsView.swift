//
//  LoadMoreListsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/21/24.
//

import SwiftUI

struct LoadMoreListsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    var collectionName: String
    @State var nameLists: [NameList] = []
    @State var loadList = ""
    @State var showingLoadList = false
    @State var moreLists: MoreLists?
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    ForEach(nameLists, id: \.id) { item in
                        NavigationLink(item.name, value: item.name)
                            .buttonStyle(MoreListsButtonStyle(imageName: item.imageName, loadList: $loadList, name: item.name))
                    }
                    .navigationDestination(for: String.self) { string in
                        DetailMoreListsView(collectionName: collectionName, listName: string, lists: moreLists?.lists ?? [[:]])
                    }
                }
            }
            .padding([.leading, .trailing], 20)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Select A List:").font(.title)
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .alert("Load This List?", isPresented: $showingLoadList) {
                Button("OK", action: { loadTheList() })
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("This will delete what's in your 'My List'. Be sure to save your current list before loading this list.")
            }
            .onAppear {
                if let userId = userAuth.user?.uid {
                    Task {
                        do {
                            if let results = try await firebaseService.getListsForUser(userId: userId, collectionName: collectionName) {
                                DispatchQueue.main.async {
                                    self.moreLists = results
                                    self.nameLists = results.listNames
                                }
                            }
                        }
                    }
                }
            }
            .onChange(of: loadList) {
                showingLoadList = true
            }
        }
    }
    
    func loadTheList() {
        if let lists = moreLists?.lists {
            var array: [String] = []
            for dict in lists {
                if let nameList = dict[loadList] {
                    array = nameList.map { $0.name }
                    break
                }
            }
            Task {
                if let userId = userAuth.user?.uid {
                    await firebaseService.updateItem(userId: userId, items: array, listName: "currentItems", collectionName: "users")
                }
            }
            dismiss()
        }
    }
}
