//
//  ConnectionView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/5/24.
//

import SwiftUI

struct ConnectionView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @Environment(\.dismiss) var dismiss
    @Binding var addUserId: String
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(firebaseService.users, id: \.id) { user in
                        VStack(alignment: .leading) {
                            Text("Name")
                                .font(.caption)
                            Text(user.displayName ?? "n/a")
                            Text("Email")
                                .font(.caption)
                            Text(user.email ?? "n/a")
                        }
                        .onTapGesture {
                            addUserId = user.id ?? "no id"
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
            }
        }
    }
}
