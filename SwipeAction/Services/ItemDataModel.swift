//
//  ItemDataModel.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/2/24.
//

import SwiftUI

struct ItemData: Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var isStrikethrough = false
    var imageName = "square"
}

class ItemDataModel: ObservableObject {
    @Published var items: [ItemData] = []
    
    func restore(key: String) {
        self.items = []
        let userDefaults = UserDefaults.standard
        let savedItems = userDefaults.array(forKey: key) as? [String]
        var array: [ItemData] = []
        if let items = savedItems {
            for item in items {
                let new = ItemData(id: UUID().uuidString, name: item)
                array.append(new)
            }
            self.items = array
        }
    }
    
    func save(key: String, items: [ItemData]) {
        var array: [String] = []
        for item in items {
            array.append(item.name)
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(array, forKey: key)
    }
    
    func setDefaults() {
        restore(key: "defaultItems")
        save(key: "currentItems", items: items)
    }
    
}
