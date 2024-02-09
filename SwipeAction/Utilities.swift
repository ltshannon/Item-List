//
//  Utilities.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/3/24.
//

import Foundation
import SwiftUI

enum ListItemType: String {
    case currentItems = "currentItems"
    case defaultItems = "defaultItems"
    case sharedItems = "sharedItems"
}

class Utilities {
    static let shared = Utilities()
    
    init() {
        
    }
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        let controller = controller ?? UIApplication
            .shared
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last?.rootViewController
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
}

extension Font {
    static let buttonText: Font = Font.system(size: 19, weight: .regular).leading(.loose)
}

public extension String {
    //Common
    static var empty: String { "" }
    static var space: String { " " }
    static var comma: String { "," }
    static var newline: String { "\n" }
    
    //Debug
    static var success: String { "🎉" }
    static var test: String { "🧪" }
    static var notice: String { "⚠️" }
    static var warning: String { "🚧" }
    static var fatal: String { "☢️" }
    static var reentry: String { "⛔️" }
    static var stop: String { "🛑" }
    static var boom: String { "💥" }
    static var sync: String { "🚦" }
    static var key: String { "🗝" }
    static var bell: String { "🔔" }
    
    var isNotEmpty: Bool {
        !isEmpty
    }
}
