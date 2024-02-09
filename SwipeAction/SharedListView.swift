//
//  SharedListView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/8/24.
//

import SwiftUI

struct SharedListView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @State var nameList: [NameList] = []
    @State var showingSheet = false
    @State var userId = ""

    var body: some View {
        VStack {
            List {
                ForEach(nameList, id: \.id) { item in
                    Text(item.name)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            userId = item.id
                            showingSheet = true
                        }
                }
            }
        }
        .onAppear {
            Task {
                await firebaseService.getSharedUsers()
            }
        }
        .onReceive(firebaseService.$sharingUsers) { items in
            var array: [NameList] = []
            for item in items {
                if let id = item.id, let name = item.displayName {
                    let nameList = NameList(id: id, name: name)
                    array.append(nameList)
                }
            }
            DispatchQueue.main.async {
                self.nameList = array
            }
        }
        .fullScreenCover(isPresented: $showingSheet) {
            ListItemsView(userId: userId, key: ListItemType.sharedItems, title: "Items", showShare: false, showDone: true)
        }
    }
}

#Preview {
    SharedListView()
}
