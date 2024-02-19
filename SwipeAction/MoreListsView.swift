//
//  MoreListsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/11/24.
//

import SwiftUI

struct MoreListsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @State var moreLists: [NameList] = []
    @State var name = ""
    @State var showingAlert = false
    @State var showingAlert2 = false
    @State var showingAlert2Text = ""
    @State var firstTime = true
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(firebaseService.moreLists.listNames, id: \.id) { item in
                        NavigationLink(item.name, value: item.name)
                            .swipeActions(edge: .trailing) {
                                Button {
                                    Task {
                                        await deleteItem(item: item.name)
                                    }
                                } label: {
                                    Text("Delete")
                                }
                            }
                    }
                }
                .navigationDestination(for: String.self) { string in
                    DetailMoreListsView(listName: string, lists: firebaseService.moreLists.lists)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("Your other lists:").font(.title)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Add item", isPresented: $showingAlert, actions: {
                TextField("Name", text: $name)
                Button("Save", action: {
                    Task {
                        await saveItem()
                    }
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Enter item name")
            })
            .onAppear {
                if firstTime, let userId = userAuth.user?.uid {
                    firebaseService.getMoreLists(docID: userId)
                }
            }
        }
        
    }
    
    func saveItem() async {
        if name.isEmpty {
            showingAlert2Text = "No item to add"
            showingAlert2 = true
            return
        }

        if firebaseService.moreLists.listNames.contains(where: { $0.name == name }) {
            showingAlert2Text = "Name already in list"
            showingAlert2 = true
            name = ""
            return
        }
        
        if let user = userAuth.user {
            await firebaseService.updateItemsForMoreItems(userId: user.uid, listName: "lists", item: name)
        } else {
            debugPrint(String.boom, "MoreListsViewsaveName could not get userId")
        }
        name = ""
    }
    
    func deleteItem(item: String) async {
        if let user = userAuth.user {
            let result = await firebaseService.deleteFieldFromMoreItems(docID: user.uid, listName: item)
            if result {
                await firebaseService.deleteMoreItem(userId: user.uid, listName: "lists", item: item)
            }
        }
    }
}
