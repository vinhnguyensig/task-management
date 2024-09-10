//
//  TaskManagementApp.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

@main
struct TaskManagementApp: App {
    init() {
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    var body: some Scene {
        WindowGroup {
            TaskTabBarView()
        }
    }
}

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Handle foreground notification
        completionHandler([.banner, .sound])
    }
}
