//
//  TaskManagementApp.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

@main
struct TaskManagementApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            if let _ = UserDefaultsManager.get(forKey: Constants.isReopenApp) {
                //TaskTabBarView()
                GoogleSigninView()
            } else {
                WalkthroughView()
            }
        }
    }
}
