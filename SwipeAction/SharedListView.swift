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
        NavigationStack {
            VStack {
                List {
                    ForEach(nameList, id: \.id) { item in
                        NavigationLink(item.name) {
                            ListItemsView(userId: item.id, key: ListItemType.sharedItems, title: "\(item.name)'s Items", showShare: false, showDone: true)
                                .navigationBarBackButtonHidden(true)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("These people are sharing to you:").font(.title2)
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
        }
    }
}

#Preview {
    SharedListView()
}
