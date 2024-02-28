//
//  MediumSizeView.swift
//  MyListsWidgetExtension
//
//  Created by Larry Shannon on 2/27/24.
//

import SwiftUI
import WidgetKit

struct MediumSizeView: View {
    var entry: Provider.Entry
    
    var body: some View {
        GroupBox {
            HStack {
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                Divider()
                VStack(alignment: .leading) {
                    Text("List title")
                        .font(.headline)
                    Text("Completed")
                        .font(.subheadline)
                }
            }
            .padding()
        } label: {
            Label("My Lists", systemImage: "list.dash")
        }
    }
}
