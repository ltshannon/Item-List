//
//  ContentView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/1/24.
//

import SwiftUI


struct ContentView: View {
    
    var body: some View {
        ListItemsView(key: "currentItems", title: "Items")
    }

}

#Preview {
    ContentView()
}
