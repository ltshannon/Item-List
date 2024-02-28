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
        default:
            Text("N/A")
        }
    }
}
