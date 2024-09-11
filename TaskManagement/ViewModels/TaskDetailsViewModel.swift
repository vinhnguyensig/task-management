//
//  TaskDetailsViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation

import Combine

@MainActor
class TaskDetailsViewModel: ObservableObject {
    @Published var task: Task?
    
    private var notificationObserver: AnyCancellable?
    
    func registerObserveTaskInfo() {
        if notificationObserver == nil {
            notificationObserver = NotificationCenter.default.publisher(for: Notification.Name(Constants.taskNotificationInfo))
                .sink {[weak self] notification in
                    if let userInfo = notification.userInfo, let taskInfo = userInfo["task"] as? Task {
                        self?.task = taskInfo
                    }
                }
        }
    }
    
    func isSetReminder(id: String) -> Bool {
        if let _ = UserDefaultsManager.get(forKey: id) {
            return true
        }
        return false
    }
    
    deinit {
        notificationObserver = nil
    }
}
