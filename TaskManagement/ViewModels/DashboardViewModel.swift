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
    @Published var tasksByCategory: [(category: TaskCategory?, tasks: [TaskModel])] = []
    @Published var tasksInProgress: [TaskModel] = []
    @Published var tasksTodayStatus: String = ""
    @Published var tasksTodayProgress: Double = 0.1
    @Published var errorMessage: String?

    private var notificationObserver: AnyCancellable?

    init() {
        registerObserveTaskInfo()
        loadData()
    }

    // Load all data in one go when ViewModel initializes
    func loadData() {
        Task {
            await loadTodayProgress()
            await loadProgressTask()
            await loadGroupTasks()
        }
    }

    // Fetch today's task progress and update UI
    func loadTodayProgress() async {
        TaskManagerDB.shared.fetchTodayTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                guard !loadedTasks.isEmpty else {
                    self?.updateTodayProgress(progress: 0)
                    return
                }
                
                let completeTasks = loadedTasks.filter { $0.isCompleted }
                let progress = Double(completeTasks.count) / Double(loadedTasks.count)
                self?.updateTodayProgress(progress: progress)
            case .failure(let error):
                self?.handleError("Failed to load today's tasks", error: error)
            }
        }
    }

    // Load tasks that are currently in progress and sort them by priority
    func loadProgressTask() async {
        TaskManagerDB.shared.getInProgressTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                let sortedTasks = loadedTasks.sorted { $0.priority < $1.priority }
                self?.tasksInProgress = sortedTasks
            case .failure(let error):
                self?.handleError("Failed to load in-progress tasks", error: error)
            }
        }
    }

    // Fetch all tasks, group by category, and sort by the number of tasks in each category
    func loadGroupTasks() async {
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
                self?.handleError("Failed to load grouped tasks", error: error)
            }
        }
    }

    // Set up an observer for task info updates (notifications)
    func registerObserveTaskInfo() {
        if notificationObserver == nil {
            notificationObserver = NotificationCenter.default.publisher(for: Notification.Name(Constants.taskNotificationInfo))
                .sink { [weak self] _ in
                    Task {
                        await self?.loadProgressTask()
                        await self?.loadGroupTasks()
                    }
                }
        }
    }

    // Update the progress and status message for today's tasks
    private func updateTodayProgress(progress: Double) {
        DispatchQueue.main.async {
            let statusMessage = TaskProgress.getProgressMessage(progress: progress)
            self.tasksTodayProgress = progress
            self.tasksTodayStatus = statusMessage
        }
    }

    // Handle and display any errors that occur
    private func handleError(_ message: String, error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "\(message): \(error.localizedDescription)"
            print(self.errorMessage ?? "Unknown error")
        }
    }

    // Clean up the notification observer when this ViewModel is deallocated
    deinit {
        notificationObserver?.cancel()
        notificationObserver = nil
    }
}
