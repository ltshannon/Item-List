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
    @State var showingAlert3 = false
    @State var showingSheet = false
    @State var name = ""
    @State var oldName = ""
    @State var items: [ItemData] = []
    @State var selectedUser: NameList = NameList(id: "n/a", name: "n/a")
    @State var showingAlert2Text = ""
    @State var firstTime = true
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
                            .swipeActions(edge: .trailing) {
                                if key != .sharedItems {
                                    Button {
                                        Task {
                                            await deleteItem(key: key, item: item.name)
                                        }
                                    } label: {
                                        Text("Delete")
                                    }
                                    .tint(.red)
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                if key != .sharedItems {
                                    Button {
                                        oldName = item.name
                                        name = item.name
                                        showingAlert3 = true
                                    } label: {
                                        Text("Edit")
                                    }
                                }
                            }
                            .swipeActions(edge: .leading) {
                                if key == .sharedItems {
                                    Button {
                                        name = item.name
                                        Task {
                                            await saveName(key: .currentItems)
                                            name = ""
                                        }
                                    } label: {
                                        Text("Add item to my list")
                                    }
                                }
                            }
                    }
                    .onMove(perform: move)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(title).font(key == .sharedItems ? .subheadline : .title)
                    }
                }
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
                Button("Cancel", role: .cancel, action: {
                    name = ""
                })
            }, message: {
                Text("")
            })
            .alert(showingAlert2Text, isPresented: $showingAlert2) {
                Button("OK", role: .cancel) { }
            }
            .alert("Edit item", isPresented: $showingAlert3, actions: {
                TextField("Name", text: $name)
                Button("Update", action: {
                    Task {
                        await updateName()
                    }
                })
                Button("Cancel", role: .cancel, action: {
                    name = ""
                })
            }, message: {
                Text("")
            })
            .fullScreenCover(isPresented: $showingSheet) {
                ShareView()
            }
            .onAppear {
                if firstTime {
                    if firebaseService.userListener == nil {
                        firebaseService.getUsers()
                    }
                    firstTime = false
                }
            }
            .onReceive(firebaseService.$users) { items in
                processUsers(users: items)
            }
        }
    }
    
    func processUsers(users: [UserInformation]) {
        if let userId = getUserId(), let item = users.filter({ $0.id == userId }).first {
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
    
    func getCurrentItems() -> [ItemData]? {
        if let user = getUserId(), let currentUser = firebaseService.users.filter({ $0.id == user }).first, let currentItems = currentUser.currentItems  {
            var array: [ItemData] = []
            for item in currentItems {
                let new = ItemData(id: UUID().uuidString, name: item)
                array.append(new)
            }
            return array
        }
        return nil
    }
    
    func saveName(key: ListItemType) async {
        if name.isEmpty {
            showingAlert2Text = "No item to add"
            showingAlert2 = true
            return
        }
        var temp: [ItemData] = []
        if self.key == .sharedItems {
            if let items = getCurrentItems() {
                temp = items
            }
        } else {
            temp = items
        }
        if temp.contains(where: { $0.name == name }) {
            showingAlert2Text = "Name already in list"
            showingAlert2 = true
            name = ""
            return
        }
        if let user = getUserId() {
            await firebaseService.addItem(userId: user, key: key == .sharedItems ? .currentItems : key, item: name)
            if key == .sharedItems {
                let user = firebaseService.users.filter({ $0.id == userId }).first
                if let fcm = user?.fcm,  let currentUser = userAuth.user, let displayName = currentUser.displayName {
                    firebaseService.callFirebaseCallableFunction(fcm: fcm, title: "\(displayName)", body: "Is adding this to your list: \(name)", silent: false)
                }
            }
        } else {
            debugPrint(String.boom, "ListItemsView saveName could not get userId")
        }
        name = ""
    }
    
    func updateName() async {
        if name.isEmpty {
            showingAlert2Text = "No item to update"
            showingAlert2 = true
            return
        }
        Task {
            var array = items.map { $0.name }
            if let index = array.firstIndex(of: oldName), let userId = getUserId() {
                array[index] = self.name
                await firebaseService.updateItem(userId: userId, items: array)
            }
        }
    }
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    ListItemsView(userId: "", key: ListItemType.currentItems, title: "Items")
}
