//
//  NotificationService.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation
import UserNotifications
import Combine

class NotificationManager: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    
    static let shared = NotificationManager()
    
    // Published properties to notify subscribers of status or error changes
    @Published var isAuthorized: Bool = false
    @Published var isSetNotify: Bool = false
    @Published var errorMessage: String?

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    // Request permission to send notifications
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error: \(error.localizedDescription)"
                    self?.isAuthorized = false
                } else {
                    self?.isAuthorized = granted
                    if !granted {
                        self?.errorMessage = "Permission denied"
                    }
                }
            }
        }
    }
    
    // Schedule a notification to trigger after a specified time interval
    func scheduleNotification(id: String, title: String, body: String, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error scheduling notification: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self?.isSetNotify = true
                }
            }
        }
    }
    
    // Schedule a notification for a specific date and time
    func scheduleNotification(id: String, title: String, body: String, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Error scheduling notification: \(error.localizedDescription)"
                }
            } else {
                DispatchQueue.main.async {
                    self?.isSetNotify = true
                }
            }
        }
    }
    
    // Cancel all scheduled notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    // Cancel a specific notification by identifier
    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    // Handle user interaction with the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User tapped the notification with identifier: \(response.notification.request.identifier)")
        completionHandler()
    }
}
