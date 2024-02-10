//
//  ListItemsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/2/24.
//

import SwiftUI

struct ListItemsView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var userAuth: Authentication
    @Environment(\.dismiss) var dismiss
    @State var showingAlert = false
    @State var showingAlert2 = false
    @State var showingSheet = false
    @State var name = ""
    @State var items: [ItemData] = []
    var userId: String
    var key: ListItemType
    var title: String
    var showShare: Bool
    var showDone: Bool
    var showRestore: Bool
    
    init(userId: String = "", key: ListItemType, title: String, showShare: Bool = true, showDone: Bool = true, showRestore: Bool = false) {
        self.userId = userId
        self.key = key
        self.title = title
        self.showShare = showShare
        self.showDone = showDone
        self.showRestore = showRestore
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(items, id: \.id) { item in
                        Text(item.name)
                    }
                    .onMove(perform: move)
                    .onDelete { indexSet in
                        let index = indexSet[indexSet.startIndex]
                        let name = items[index].name
                        Task {
                            await deleteItem(key: key, item: name)
                        }
                        
                    }
                }
                .toolbar {
                    EditButton()
                }
                if showRestore == true {
                    VStack {
                        Button {
                            restoreDefaults()
                            dismiss()
                        } label: {
                            Text("Restore Defaults")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAlert = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                if showShare == true {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            showingSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                if showDone == true {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                    }
                }
            }
            .alert("Add item", isPresented: $showingAlert, actions: {
                TextField("Name", text: $name)
                Button("Save", action: {
                    Task {
                        await saveName(key: key)
                    }
                })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Enter item name")
            })
            .alert("Name already in list", isPresented: $showingAlert2) {
                Button("OK", role: .cancel) { }
            }
            .fullScreenCover(isPresented: $showingSheet, onDismiss: didDismiss) {
                ShareView()
            }
            .onReceive(firebaseService.$users) { items in
                if let userId = getUserId() {
                    for item in items {
                        if userId == item.id {
                            var temp: [String]?
                            switch key {
                            case .currentItems:
                                temp = item.currentItems
                            case .defaultItems:
                                temp = item.defaultItems
                            case .sharedItems:
                                temp = item.currentItems
                            }
                            if let currentItems = temp {
                                var array: [ItemData] = []
                                for item in currentItems {
                                    let new = ItemData(id: UUID().uuidString, name: item)
                                    array.append(new)
                                }
                                DispatchQueue.main.async {
                                    self.items = array
                                }
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getUserId() -> String? {
        switch key {
        case .currentItems, .defaultItems:
            if let user = userAuth.user {
                return user.uid
            }
            return nil
        case .sharedItems:
            return userId
        }
    }
    
    func restoreDefaults() {
        
        let data = items.map { $0.name }
        Task {
            await firebaseService.restoreDefault(items: data)
        }
    }
    
    func deleteItem(key: ListItemType, item: String) async {
        if let userId = getUserId() {
            await firebaseService.deleteItem(userId: userId, key: key == .sharedItems ? .currentItems : key, item: item)
        } else {
            debugPrint(String.boom, "ListItemsView deleteItem could not get userId")
        }
    }
    
    func saveName(key: ListItemType) async {
        if items.contains(where: { $0.name == name }) {
            showingAlert2 = true
            name = ""
            return
        }
        if let userId = getUserId() {
            await firebaseService.updateItems(userId: userId, key: key == .sharedItems ? .currentItems : key, item: name)
        } else {
            debugPrint(String.boom, "ListItemsView saveNamecould not get userId")
        }
        name = ""
    }
    
    func didDismiss() {

    }
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    ListItemsView(userId: "", key: ListItemType.currentItems, title: "Items")
}
