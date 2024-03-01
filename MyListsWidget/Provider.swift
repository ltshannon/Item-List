//
//  Provider.swift
//  MyListsWidgetExtension
//
//  Created by Larry Shannon on 2/27/24.
//

import WidgetKit
import SwiftUI
import Firebase

struct Provider: TimelineProvider {
    var firebaseService = FirebaseService.shared
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), items: [NameList(id: UUID().uuidString, name: "No Items", imageName: "")])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), items: [])
        completion(entry)
        Task {
            let arrayItems = Array(await getData().prefix(2))
            let entry = SimpleEntry(date: .now, items: arrayItems)
            completion(entry)
        }
    }
    
    func getData() async -> [NameList] {
        
        if let user = await firebaseService.getUserDataForWidget() {
            if let array = user.currentItems {
                var arrayItems: [NameList] = []
                for item in array {
                    let item = NameList(id: UUID().uuidString, name: item, imageName: "circle")
                    arrayItems.append(item)
                }
                return arrayItems
            }
        }
        return []
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {

        Task {
            let arrayItems = Array(await getData().prefix(7))
            let entry = SimpleEntry(date: .now, items: arrayItems)
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
            return
        }
    }
}
