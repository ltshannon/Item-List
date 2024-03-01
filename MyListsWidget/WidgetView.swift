//
//  WidgetView.swift
//  MyListsWidgetExtension
//
//  Created by Larry Shannon on 2/27/24.
//

import WidgetKit
import SwiftUI

struct WidgetView: View {
    @Environment(\.widgetFamily) var widgetFanily
    var entry: Provider.Entry

    var body: some View {
        switch widgetFanily {
        case .systemMedium:
            MediumSizeView(entry: entry)
        case .systemLarge:
            LargeSizeView(entry: entry)
        case .accessoryCircular:
            Text("this isn't working")
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
//            VStack {
//                 HStack {
//                     Image(systemName: "square")
//                     Text("Pick up the milk")
//          .font(.headline)
//                         .widgetAccentable()
//                 }
//                 HStack {
//                     Image(systemName: "square")
//                     Text("Take out the trash")
//                 }
//                 HStack {
//                     Image(systemName: "square")
//                     Text("Feed the cat")
//                 }
//             }
//             .privacySensitive()
        default:
            Text("N/A")
        }
    }
}
