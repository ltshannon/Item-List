//
//  MoreListsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/11/24.
//

import SwiftUI

struct MoreListView: View {
    var item: NameList
    
    var body: some View {
        HStack {
            Image(systemName: item.imageName)
            Text(item.name)
        }
    }
}

struct MoreListsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    var collectionName: String
    var title: String
    @State var moreLists: MoreLists?
    @State var nameLists: [NameList] = []
    @State var name = ""
    @State var oldName = ""
    @State var showingAlertSave = false
    @State var showingAlertMessage = false
    @State var showingEdit = false
    @State var showingAlertMessageText = ""
    @State var firstTime = true
 
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(nameLists, id: \.id) { item in
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
                .navigationDestination(for: String.self) { string in
                    DetailMoreListsView(collectionName: collectionName, listName: string, lists: moreLists?.lists ?? [[:]])
                }
                Button {
                    showingAlertSave = true
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(title).font(.title)
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
            .alert("Add item", isPresented: $showingAlertSave, actions: {
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
            .alert("Edit item", isPresented: $showingEdit) {
                TextField("Name", text: $name)
                Button("Update", action: {
                    Task {
                        await updateName()
                    }
                })
                Button("Cancel", role: .cancel, action: {})
            }
            .alert(showingAlertMessageText, isPresented: $showingAlertMessage) {
                Button("OK", role: .cancel) { }
            }
            .onAppear {
                if firstTime == true, let userId = userAuth.user?.uid {
                    firebaseService.getMoreLists(docID: userId, collectionName: collectionName)
                    firstTime = false
                }
            }
            .onChange(of: firebaseService.moreLists) { oldValue, newValue in
                DispatchQueue.main.async {
                    self.moreLists = newValue
                    self.nameLists = newValue.listNames
                }
            }
        }
    }
    
    func loadList() {
        
    }
    
    func updateName() async {
        if name.isEmpty {
            showingAlertMessageText = "No item to update"
            showingAlertMessage  = true
            return
        }
        if let moreLists = moreLists {
            var array = moreLists.listNames.map { $0.name }
            if let index = array.firstIndex(of: oldName), let user = userAuth.user {
                array[index] = self.name
                var oldList: [String] = []
                for a in moreLists.lists {
                    if let nameList = a[oldName] {
                        oldList = nameList.map { $0.name }
                    }
                }
                
                Task {
                    await firebaseService.updateItem(userId: user.uid, items: array, listName: "xxxLists", collectionName: collectionName)
                    let result = await firebaseService.deleteFieldFromMoreItems(docID: user.uid, listName: oldName, collectionName: collectionName)
                    if result == true {
                        await firebaseService.updateItem(userId: user.uid, items: oldList, listName: name, collectionName: collectionName)
                        await deleteItem(item: oldName)
                    }
                    DispatchQueue.main.async {
                        name = ""
                    }
                }
            }
        }
    }
    
    func saveItem() async {
        if name.isEmpty {
            showingAlertMessageText = "No item to add"
            showingAlertMessage = true
            return
        }

        if let moreLists = moreLists, moreLists.listNames.contains(where: { $0.name == name }) {
            showingAlertMessageText = "Name already in list"
            showingAlertMessage = true
            name = ""
            return
        }
        
        if let user = userAuth.user {
            await firebaseService.updateItemsForMoreItems(userId: user.uid, listName: "xxxLists", item: name, collectionName: collectionName)
        } else {
            debugPrint(String.boom, "MoreListsViewsaveName could not get userId")
        }
        name = ""
    }
    
    func deleteItem(item: String) async {
        if let user = userAuth.user {
            let result = await firebaseService.deleteFieldFromMoreItems(docID: user.uid, listName: item, collectionName: collectionName)
            if result {
                await firebaseService.deleteMoreItem(userId: user.uid, listName: "xxxLists", item: item, collectionName: collectionName)
            }
        }
    }
}
