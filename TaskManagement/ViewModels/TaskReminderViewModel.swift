//
//  TaskReminderViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import Foundation
import Combine

class TaskReminderViewModel: ObservableObject {
    @Published var notificationAuthorized: Bool = false
    @Published var errorMessage: String?
    
    private var recentAddedReminder: String = ""
    private var anyCancleables = Set<AnyCancellable>()
    
    func requestionNotifictionAuthorization() {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.$isAuthorized
            .dropFirst()
            .sink { [weak self] status in
                if status {
                    self?.notificationAuthorized = status
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = Constants.notificationPermissionDeniedMessage
                    }
                }
            }
            .store(in: &anyCancleables)
    }
    
    func setReminder(task: Task) {
        if recentAddedReminder == task.id {
            return
        }
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.$isAuthorized
            .dropFirst()
            .sink { [weak self] status in
                if status {
                    if let dueDate = task.dueDate {
                        NotificationManager.shared.scheduleNotification(id: task.id, title: task.title, body: task.brief ?? "", date: dueDate)
                        self?.recentAddedReminder = task.id
                        self?.notificationAuthorized = status
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = Constants.notificationPermissionDeniedMessage
                    }
                }
            }
            .store(in: &anyCancleables)
        
        NotificationManager.shared.$isSetNotify
            .dropFirst()
            .sink { status in
                if status {
                    UserDefaultsManager.save(value: status, forKey: task.id)
                }
            }
            .store(in: &anyCancleables)
        
        NotificationManager.shared.$errorMessage
            .dropFirst()
            .sink { [weak self] message in
                DispatchQueue.main.async {
                    self?.errorMessage = message
                }
            }
            .store(in: &anyCancleables)
    }
    
    func removeReminder(id: String) {
        NotificationManager.shared.cancelNotification(identifier: id)
        UserDefaultsManager.remove(forKey: id)
        recentAddedReminder = ""
    }
    
    func isSetReminder(id: String) -> Bool {
        if let _ = UserDefaultsManager.get(forKey: id) {
            return true
        }
        return false
    }
}
