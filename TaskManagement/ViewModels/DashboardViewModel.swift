//
//  DashboardViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var tasksByCategory: [(category: TaskCategory?, tasks: [Task])] = []
    @Published var tasksInProgress: [Task] = []
    @Published var tasksTodayStatus: String = ""
    @Published var tasksTodayProgress: Double = 0.1
    @Published var errorMessage: String?
    
    private var notificationObserver: AnyCancellable?
    
    init() {
        registerObserveTaskInfo()
    }
    
    func loadTodayProgress() {
        TaskManagerDB.shared.fetchTodayTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                if loadedTasks.count > 0 {
                    let completeTasks = loadedTasks.filter {
                        $0.isCompleted == true
                    }
                    let progress = Double(completeTasks.count)/Double(loadedTasks.count)
                    self?.updateTodayProgress(progress: progress)
                }
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    func loadProgressTask() {
        TaskManagerDB.shared.getInProgressTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                let sortedTasks = loadedTasks.sorted {
                    $0.priority < $1.priority
                }
                self?.tasksInProgress = sortedTasks
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }

    func loadGroupTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                // Group tasks by category
                let groupedTasks = Dictionary(grouping: loadedTasks) { $0.category }
                
                let sortedTasksByCategory = groupedTasks
                    .map { (category: $0.key, tasks: $0.value) }
                    .sorted { $0.tasks.count > $1.tasks.count }
                
                self?.tasksByCategory = sortedTasksByCategory
                
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    func registerObserveTaskInfo() {
        if notificationObserver == nil {
            notificationObserver = NotificationCenter.default.publisher(for: Notification.Name(Constants.taskNotificationInfo))
                .sink {[weak self] notification in
                    if let _ = notification.userInfo {
                        self?.loadProgressTask()
                        self?.loadGroupTasks()
                    }
                }
        }
    }
    
    private func updateTodayProgress(progress: Double) {
        DispatchQueue.main.async {
            let statusMessage = self.taskStatusMessage(progress: progress)
            self.tasksTodayProgress = progress
            self.tasksTodayStatus = statusMessage
        }
    }
    
    private func taskStatusMessage(progress: Double) -> String {
        var message = ""
        switch progress {
        case 0.0:
            message = "Let's get started!"
        case 0.0..<0.3:
            message = "Good start! Keep going!"
        case 0.3..<0.6:
            message = "You're making progress!"
        case 0.6..<0.8:
            message = "You're more than halfway there!"
        case 0.8..<1.0:
            message = "Almost done!"
        case 1.0:
            message = "Great job! You've completed everything for today!"
        default:
            message = "Keep pushing forward!"
        }
        return message
    }
    
    deinit {
        notificationObserver = nil
    }
}
