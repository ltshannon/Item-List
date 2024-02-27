//
//  DetailMoreListsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/16/24.
//

import SwiftUI

struct DetailMoreListsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    var collectionName: String
    var listName: String
    var lists: [[String: [NameList]]]
    @State var listItems: [NameList] = []
    @State var showingAlert = false
    @State var showingAlert2 = false
    @State var showingEdit = false
    @State var showingAlert2Text = ""
    @State var name = ""
    @State var oldName = ""
    
    var body: some View {
        
        VStack {
            List {
                ForEach(listItems, id: \.id) { item in
                    Text(item.name)
                        .swipeActions(edge: .trailing) {
                            Button {
                                Task {
                                    await deleteItem(item: item.name)
                                }
                            } label: {
                                Text("Delete")
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                oldName = item.name
                                name = item.name
                                showingEdit = true
                            } label: {
                                Text("Edit")
                            }
                        }
                }
            }
            Button {
                showingAlert = true
            } label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
        }
        .onAppear {
            for item in lists {
                if let element = item[listName] {
                    listItems = element
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("\(listName)").font(.headline)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    restoreList()
                } label: {
                    Text("Restore List")
                }
            }
        }
        .alert("Add item", isPresented: $showingAlert, actions: {
            TextField("Item", text: $name)
            Button("Save", action: {
                Task {
                    await saveItem()
                }
            })
            Button("Save and continue adding", action: {
                Task {
                    await saveItem()
                    showingAlert = true
                }
            })
            Button("Cancel", role: .cancel, action: {})
        }, message: {
            Text("Enter item name")
        })
        .alert(showingAlert2Text, isPresented: $showingAlert2) {
            Button("OK", role: .cancel) { }
        }
        .alert("Edit item", isPresented: $showingEdit) {
            TextField("Name", text: $name)
            Button("Update", action: {
                Task {
                    await updateName()
                }
            })
            Button("Cancel", role: .cancel, action: {})
        }
    }
    
    func restoreList() {
        if let user = userAuth.user {
            let array = listItems.map { $0.name }
            Task {
                await firebaseService.updateItem(userId: user.uid, items: array, listName: "currentItems", collectionName: "users")
                DispatchQueue.main.async {
                    dismiss()
                }
            }
        }
    }
        
    func updateName() async {
        if name.isEmpty {
            showingAlert2Text = "No item to update"
            showingAlert2  = true
            return
        }
        var array = listItems.map { $0.name }
        if let index = array.firstIndex(of: oldName), let user = userAuth.user {
            array[index] = self.name
            Task {
                await firebaseService.updateItem(userId: user.uid, items: array, listName: listName, collectionName: collectionName)
                DispatchQueue.main.async {
                    listItems[index].name = name
                    name = ""
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

        if listItems.contains(where: { $0.name == name }) {
            showingAlert2Text = "Name already in list"
            showingAlert2 = true
            name = ""
            return
        }
        
        if let user = userAuth.user {
            await firebaseService.updateItemsForMoreItems(userId: user.uid, listName: listName, item: name, collectionName: collectionName)
            let item = NameList(id: UUID().uuidString, name: name)
            listItems.append(item)
            name = ""
        } else {
            debugPrint(String.boom, "MoreListsViewsaveName could not get userId")
        }
    }
    
    func deleteItem(item: String) async {
        if let user = userAuth.user {
            await firebaseService.deleteMoreItem(userId: user.uid, listName: listName, item: item, collectionName: collectionName)
            listItems.removeAll(where: { $0.name == item } )
        }
    }
    
}
