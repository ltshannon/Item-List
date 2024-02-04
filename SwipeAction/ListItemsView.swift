//
//  ListItemsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/2/24.
//

import SwiftUI

struct ListItemsView: View {
    @EnvironmentObject var itemDataModel: ItemDataModel
    @Environment(\.dismiss) var dismiss
    @State var showingAlert = false
    @State var showingSheet = false
    @State var name = ""
    @State var items: [ItemData] = []
    var key: String
    var title: String
    var showGear: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(items, id: \.id) { item in
                        Text(item.name)
                    }
                    .onMove(perform: move)
                    .onDelete { indexSet in
                        items.remove(atOffsets: indexSet)
                        itemDataModel.save(key: key, items: items)
                    }
                }
                .toolbar {
                    EditButton()
                }
                if showGear == false {
                    HStack {
                        Button {
                            itemDataModel.setDefaults()
                            dismiss()
                        } label: {
                            Text("Restore Defaults")
                        }
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
                if showGear == true {
                    ToolbarItem(placement: .confirmationAction) {
                        Button {
                            showingSheet = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                if showGear == false {
                    ToolbarItem(placement: .cancellationAction) {
                        Button {
                            itemDataModel.restore(key: "currentItems")
                            dismiss()
                        } label: {
                            Text("Done")
                        }
                    }
                }
            }
            .alert("Add item", isPresented: $showingAlert, actions: {
                TextField("Name", text: $name)
                Button("Save", action: { saveName(key: key) })
                Button("Cancel", role: .cancel, action: {})
            }, message: {
                Text("Enter item name")
            })
            .fullScreenCover(isPresented: $showingSheet, onDismiss: didDismiss) {
                SettingsView()
            }
            .onAppear {
                itemDataModel.restore(key: key)
                items = itemDataModel.items
            }
        }
    }
    
    func saveName(key: String) {
        let item = ItemData(name: name)
        items.append(item)
        name = ""
        itemDataModel.save(key: key, items: items)
    }
    
    func didDismiss() {
        items = itemDataModel.items
    }
    
    func move(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
}

#Preview {
    ListItemsView(key: "currentItems", title: "Items")
}
