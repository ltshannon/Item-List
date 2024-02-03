//
//  SwipeActionApp.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/1/24.
//

import SwiftUI

@main
struct SwipeActionApp: App {
    @StateObject var itemDataModel = ItemDataModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(itemDataModel)
        }
    }
}
