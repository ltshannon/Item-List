//
//  SettingsView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/2/24.
//

import SwiftUI

struct SettingsView: View {

    var body: some View {
        ListItemsView(key: "defaultItems", title: "Default Items", showGear: false)
    }
    
}

#Preview {
    SettingsView()
}
