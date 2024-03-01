//
//  SimpleEntry.swift
//  MyListsWidgetExtension
//
//  Created by Larry Shannon on 2/27/24.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let id = UUID().uuidString
    let date: Date
    var items: [NameList]
}

