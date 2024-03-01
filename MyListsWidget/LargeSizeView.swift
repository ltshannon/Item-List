//
//  LargeSizeView.swift
//  MyListsWidgetExtension
//
//  Created by Larry Shannon on 2/27/24.
//

import SwiftUI
import WidgetKit

struct LargeSizeView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                Text("My Lists")
                Text(Date.now, format: .dateTime)
                Spacer()
            }
            .padding(8)
            .background(.blue)
            .foregroundColor(.white)
            .clipped()
            .shadow(radius: 5)
        }
        ForEach(entry.items, id: \.id) { item in
            HStack {
//                Image(systemName: "checkmark.circle")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 30, height: 30)
                Text(item.name)
                Spacer()
            }
            .padding(.horizontal)
            Divider()
        }
    }
}
