//
//  SwipeActionApp.swift
//  SwipeAction
//
//  Created by Larry Shannon on 2/1/24.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import GoogleSignIn

class AppDelegate: NSObject,  UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        debugPrint("🧨", "willPresent")
        process(notification)
        completionHandler([[.banner, .sound]])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        debugPrint("🧨", "didReceive ")
        process(response.notification)
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        
        debugPrint("🧨", "didReceiveRemoteNotification userInfo: \(userInfo)")
        
        if let title = userInfo["title"] as? String, let body = userInfo["body"] as? String {
            let dataDict: [String: String] = ["key1": title, "key2" : body]
            NotificationCenter.default.post(
                name: Notification.Name("silent"),
                object: nil,
                userInfo: dataDict
            )
        }
        
        return UIBackgroundFetchResult.newData
        
    }
    
    func application(application: UIApplication,  didReceiveRemoteNotification userInfo: [NSObject : AnyObject],  fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        debugPrint("🧨", "didReceiveRemoteNotification ")
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        debugPrint("🧨", "Firebase fcm token: \(String(describing: fcmToken))")
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: tokenDict)
    }

    private func process(_ notification: UNNotification) {
        let _ = notification.request.content.userInfo
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            debugPrint("Error setBadgeCount: \(error.debugDescription)")
        }
    }
}

@main
struct SwipeActionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var itemDataModel = ItemDataModel()
    @StateObject var userAuth = Authentication.shared
    @StateObject var firebaseService = FirebaseService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(itemDataModel)
                .environmentObject(userAuth)
                .environmentObject(firebaseService)
        }
    }
}
