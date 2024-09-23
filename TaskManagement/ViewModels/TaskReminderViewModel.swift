//
//  TaskReminderViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import Foundation
import Combine

class TaskReminderViewModel: ObservableObject {
    // Published properties for UI binding
    @Published var notificationAuthorized: Bool = false
    @Published var errorMessage: String?
    
    private var recentAddedReminder: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Request Notification Authorization
    
    // Request notification permission and update the authorization status
    func requestNotificationAuthorization() {
        NotificationManager.shared.requestAuthorization()
        
        NotificationManager.shared.$isAuthorized
            .dropFirst() // Ignore the initial value
            .sink { [weak self] isAuthorized in
                if isAuthorized {
                    self?.notificationAuthorized = true
                } else {
                    self?.handleError(Constants.notificationPermissionDeniedMessage)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Reminder Management
    
    // Set a reminder for a task, ensuring authorization is requested first
    func setReminderWithAuthorization(task: TaskModel) {
        // Avoid adding duplicate reminders
        guard recentAddedReminder != task.id else { return }
        
        requestNotificationAuthorization()
        
        NotificationManager.shared.$isAuthorized
            .dropFirst()
            .sink { [weak self] isAuthorized in
                guard isAuthorized, let dueDate = task.dueDate else { return }
                // Schedule the notification if authorized
                NotificationManager.shared.scheduleNotification(
                    id: task.id, title: task.title, body: task.brief ?? "", date: dueDate
                )
                self?.recentAddedReminder = task.id
            }
            .store(in: &cancellables)
        
        // Monitor notification setup status
        observeNotificationStatus(for: task.id)
    }

    // Add a reminder for the task directly (without authorization request)
    func addReminder(task: TaskModel) {
        // Skip duplicate reminders
        guard recentAddedReminder != task.id, let dueDate = task.dueDate else { return }
        
        NotificationManager.shared.scheduleNotification(
            id: task.id, title: task.title, body: task.brief ?? "", date: dueDate
        )
        UserDefaultsManager.save(value: true, forKey: task.id)
        recentAddedReminder = task.id
    }
    
    // Update the reminder if it is already set
    func updateReminder(task: TaskModel) {
        // Cancel existing reminder if set
        if isReminderSet(id: task.id) {
            NotificationManager.shared.cancelNotification(identifier: task.id)
        }
        // Set a new reminder
        if let dueDate = task.dueDate {
            NotificationManager.shared.scheduleNotification(
                id: task.id, title: task.title, body: task.brief ?? "", date: dueDate
            )
            UserDefaultsManager.save(value: true, forKey: task.id)
            recentAddedReminder = task.id
        }
    }
    
    // Remove a reminder by its task ID
    func removeReminder(id: String) {
        NotificationManager.shared.cancelNotification(identifier: id)
        UserDefaultsManager.remove(forKey: id)
        recentAddedReminder = ""
    }
    
    // Check if a reminder is already set
    func isReminderSet(id: String) -> Bool {
        return UserDefaultsManager.get(forKey: id) != nil
    }
    
    // MARK: - Notification Observers
    
    // Observe the notification setup status and save in user defaults
    private func observeNotificationStatus(for taskId: String) {
        NotificationManager.shared.$isSetNotify
            .dropFirst()
            .sink { isSet in
                if isSet {
                    UserDefaultsManager.save(value: true, forKey: taskId)
                }
            }
            .store(in: &cancellables)
        
        // Observe and handle error messages from the notification manager
        NotificationManager.shared.$errorMessage
            .dropFirst()
            .sink { [weak self] message in
                self?.handleError(message ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Error Handling
    
    // Centralized error handling
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
        }
        print(message)
    }
}
