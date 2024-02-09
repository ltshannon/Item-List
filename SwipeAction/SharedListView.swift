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

    var body: some View {
        VStack {
            List {
                ForEach(nameList, id: \.id) { item in
                    Text(item.name)
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

#Preview {
    SharedListView()
}
