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
    @State var showingAddItem = false
    @State var showingAlertMessage = false
    @State var showingEdit = false
    @State var showingDeleteChecked = false
    @State var showingDeleteAll = false
    @State var showingCheckedAll = false
    @State var showingUnchecked = false
    @State var showingDefaultList = false
    @State var showingMoreLists = false
    @State var showingShareSheet = false
    @State var showingShareSheetLoadMore = false
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
                        HStack {
                            Image(systemName: item.imageName)
                            Text(item.name)
                                .strikethrough(item.isStrikethrough)
                                .swipeActions(edge: .trailing) {
                                    Button {
                                        Task {
                                            await deleteItem(key: key, item: item.name)
                                        }
                                    } label: {
                                        Text("Delete")
                                    }
                                    .tint(.red)
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
                        .onTapGesture {
                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                items[index].isStrikethrough.toggle()
                                if items[index].isStrikethrough {
                                    items[index].imageName = "checkmark.circle"
                                } else {
                                    items[index].imageName = "circle"
                                }
                            }
                        }
                    }
                    .onMove(perform: move)
                }
//                if showRestore == true {
//                    Button {
//                        restoreDefaults()
//                        dismiss()
//                    } label: {
//                        Text("Restore Defaults")
//                    }
//                    .buttonStyle(.bordered)
//                }
                Button {
                    showingAddItem = true
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
                        Text(title).font(key == .sharedItems ? .subheadline : .title)
                    }
                }
                if key == .currentItems {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Button {
                                showingShareSheet = true
                            } label: {
                                HStack {
                                    Text("Share List")
                                    Image(systemName: "square.and.arrow.up")
                                }
                            }
                            Button {
                                showingDeleteChecked = true
                            } label: {
                                HStack {
                                    Text("Delete Checked")
                                    Image(systemName: "trash")
                                }
                            }
                            Button {
                                showingDeleteAll = true
                            } label: {
                                HStack {
                                    Text("Delete All")
                                    Image(systemName: "trash")
                                }
                            }
                            Button {
                                showingCheckedAll = true
                            } label: {
                                HStack {
                                    Text("Check All")
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                showingUnchecked = true
                            } label: {
                                HStack {
                                    Text("Uncheck All")
                                    Image(systemName: "circle")
                                }
                            }
                            Button {
                                showingDefaultList = true
                            } label: {
                                HStack {
                                    Text("Load Default List")
                                    Image(systemName: "checklist")
                                }
                            }
                            Button {
                                showingShareSheetLoadMore = true
                                //                            showingMoreLists = true
                            } label: {
                                HStack {
                                    Text("Load a list from 'More Lists'")
                                    Image(systemName: "checklist")
                                }
                            }
                        } label: {
                            Label("Menu", systemImage: "ellipsis.circle")
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
            .alert("Add item", isPresented: $showingAddItem, actions: {
                TextField("Name", text: $name)
                Button("Save", action: {
                    Task {
                        await saveName(key: key)
                    }
                })
                Button("Save and continue adding", action: {
                    Task {
                        await saveName(key: key)
                        showingAddItem = true
                    }
                })
                Button("Cancel", role: .cancel, action: {
                    name = ""
                })
            }, message: {
                Text("")
            })
            .alert(showingAlert2Text, isPresented: $showingAlertMessage) {
                Button("OK", role: .cancel) { }
            }
            .alert("Delete All Checked?", isPresented: $showingDeleteChecked) {
                Button("Delete", role: .destructive, action: { deleteChecked() })
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("This will delete all checked items and changes you made.")
            }
            .alert("Delete all items?", isPresented: $showingDeleteAll) {
                Button("Delete", role: .destructive, action: { deleteAll() })
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("This will delete all items and changes you made.")
            }
            .alert("Check all items?", isPresented: $showingCheckedAll) {
                Button("OK", action: { checkAll() })
                Button("Cancel", role: .cancel, action: {})
            }
            .alert("Uncheck all items?", isPresented: $showingUnchecked) {
                Button("OK", action: { uncheckAll() })
                Button("Cancel", role: .cancel, action: {})
            }
            .alert("Load Default List?", isPresented: $showingDefaultList) {
                Button("OK", action: { loadDefaults() })
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("This will replace what is in your 'My List'")
            }
            .alert("Load a list from the 'More Lists'?", isPresented: $showingMoreLists) {
                Button("OK", action: { showingShareSheetLoadMore = true })
                Button("Cancel", role: .cancel, action: {})
            } message: {}
            .alert("Edit item", isPresented: $showingEdit) {
                TextField("Name", text: $name)
                Button("Update", action: {
                    Task {
                        await updateName()
                    }
                })
                Button("Cancel", role: .cancel, action: {
                    name = ""
                })
            } message: {
                Text("")
            }
            .fullScreenCover(isPresented: $showingShareSheet) {
                ShareView()
            }
            .fullScreenCover(isPresented: $showingShareSheetLoadMore) {
                LoadMoreListsView()
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
                if let userId = getUserId() {
                    let array = processUsers(userId: userId, listType: key, users: items)
                    DispatchQueue.main.async {
                        self.items = array
                    }
                }
            }
        }
    }
    
    func processUsers(userId: String, listType: ListItemType, users: [UserInformation]) -> [ItemData] {
        if let item = users.filter({ $0.id == userId }).first {
            var temp: [String]?
            switch listType {
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
                    let element = items.filter({ $0.name == item }).first
                    let new = ItemData(id: UUID().uuidString, name: item, isStrikethrough: element?.isStrikethrough ?? false, imageName: element?.imageName ?? "circle")
                    array.append(new)
                }
                return array
            }
        }
        return []
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
    
    func loadDefaults() {
        if let user = userAuth.user {
            let itemData = processUsers(userId: user.uid, listType: .defaultItems, users: firebaseService.users)
            let array = itemData.map { $0.name }
            Task {
                await firebaseService.updateItem(userId: user.uid, items: array, listName: "currentItems", collectionName: "users")
            }
        }
        
    }
    
    func restoreDefaults() {
        let data = items.map { $0.name }
        Task {
            await firebaseService.restoreDefault(items: data)
        }
    }
    
    func deleteChecked() {
        let temp = items.filter { $0.isStrikethrough == false }
        let array = temp.map { $0.name }
        if let userId = getUserId() {
            Task {
                await firebaseService.updateItem(userId: userId, items: array, listName: "currentItems", collectionName: "users")
                DispatchQueue.main.async {
                    name = ""
                }
            }
        }
    }
    
    func deleteAll() {
        if let userId = getUserId() {
            Task {
                await firebaseService.updateItem(userId: userId, items: [], listName: "currentItems", collectionName: "users")
                DispatchQueue.main.async {
                    name = ""
                }
            }
        }
    }
    
    func checkAll() {
        for (index, _) in items.enumerated() {
            items[index].imageName = "checkmark.circle"
            items[index].isStrikethrough = true
        }
    }
    
    func uncheckAll() {
        for (index, _) in items.enumerated() {
            items[index].imageName = "circle"
            items[index].isStrikethrough = false
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
            showingAlertMessage = true
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
            showingAlertMessage = true
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
            showingAlertMessage = true
            return
        }
        var array = items.map { $0.name }
        if let index = array.firstIndex(of: oldName), let userId = getUserId() {
            array[index] = self.name
            Task {
                await firebaseService.updateItem(userId: userId, items: array, listName: key.rawValue, collectionName: "users")
                DispatchQueue.main.async {
                    name = ""
                }
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
