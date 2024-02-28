//
//  MyListsWidget.swift
//  MyListsWidget
//
//  Created by Larry Shannon on 2/27/24.
//

import WidgetKit
import SwiftUI

struct MyListsWidget: Widget {
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
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName("My Lists")
        .description("View your current list")
    }
}

#Preview(as: .systemSmall) {
    MyListsWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
