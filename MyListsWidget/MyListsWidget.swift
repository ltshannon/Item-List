//
//  MyListsWidget.swift
//  MyListsWidget
//
//  Created by Larry Shannon on 2/27/24.
//

import WidgetKit
import SwiftUI
import Firebase

struct MyListsWidget: Widget {
    
    init() {
        FirebaseApp.configure()
        do {
            try Auth.auth().useUserAccessGroup("DDDAQ32TPA.com.breakawaydesign.SwipeAction")
        } catch {
            debugPrint(String.boom, "Auth.auth().useUserAccessGroup failed: \(error.localizedDescription)")
        }
    }

    let kind: String = "MyListsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .supportedFamilies([.systemLarge, .accessoryRectangular])
        .configurationDisplayName("My Lists")
        .description("View your current list")
    }
}

#Preview(as: .systemSmall) {
    MyListsWidget()
} timeline: {
    SimpleEntry(date: .now, items: [])
    SimpleEntry(date: .now, items: [])
}
