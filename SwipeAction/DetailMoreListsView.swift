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
    var listName: String
    var lists: [[String: [NameList]]]
    @State var listItems: [NameList] = []
    @State var showingAlert = false
    @State var showingAlert2 = false
    @State var showingAlert2Text = ""
    @State var name = ""
    
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
//            ToolbarItem(placement: .primaryAction) {
//                Button {
//                    showingAlert = true
//                } label: {
//                    Image(systemName: "plus")
//                }
//            }
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
            await firebaseService.updateItemsForMoreItems(userId: user.uid, listName: listName, item: name)
            let item = NameList(id: UUID().uuidString, name: name)
            listItems.append(item)
            name = ""
        } else {
            debugPrint(String.boom, "MoreListsViewsaveName could not get userId")
        }
    }
    
    func deleteItem(item: String) async {
        if let user = userAuth.user {
            await firebaseService.deleteMoreItem(userId: user.uid, listName: listName, item: item)
            listItems.removeAll(where: { $0.name == item } )
        }
    }
    
}
