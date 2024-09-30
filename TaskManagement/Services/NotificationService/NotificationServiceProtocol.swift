//
//  NotificationServiceProtocol.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation
import Combine

protocol NotificationServiceProtocol {
    // Properties
    var isAuthorizedPublisher: AnyPublisher<Bool, Never> { get }
    var isSetNotifyPublisher: AnyPublisher<Bool, Never> { get }
    var errorMessagePublisher: AnyPublisher<String?, Never> { get }

    // Request permission to send notifications
    func requestAuthorization()
    
    // Schedule a notification to trigger after a specified time interval
    func scheduleNotification(id: String, title: String, body: String, timeInterval: TimeInterval)
    
    // Schedule a notification for a specific date and time
    func scheduleNotification(id: String, title: String, body: String, date: Date)
    
    // Cancel all scheduled notifications
    func cancelAllNotifications()
    
    // Cancel a specific notification by identifier
    func cancelNotification(identifier: String)
}

