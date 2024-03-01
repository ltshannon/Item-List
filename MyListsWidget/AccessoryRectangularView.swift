//
//  AccessoryRectangularView.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/29/24.
//

import SwiftUI
import WidgetKit

struct AccessoryRectangularView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            ForEach(entry.items, id: \.id) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                }
                .padding(.horizontal)
                Divider()
            }
            Spacer()
        }
    }
}

