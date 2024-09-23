//
//  TaskCalendarViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import Foundation
import Combine

@MainActor
class TaskCalendarViewModel: ObservableObject {
    // Published properties for UI binding
    @Published var taskGroups: [(key: Date, value: [TaskModel])] = []
    @Published var errorMessage: String?
    
    var isSelectedDate = false
    var isSelectedToday = false
    
    private var notificationObserver: AnyCancellable?
    
    // MARK: - Initialization
    init() {
        registerObserveTaskInfo()
        loadTasks()
    }
    
    // MARK: - Load and Group Tasks
    
    // Fetch all tasks and group by dates
    func loadTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasksInDates(tasks: loadedTasks)
            case .failure(let error):
                self?.handleError("Failed to load tasks: \(error.localizedDescription)")
            }
        }
    }

    // Group tasks by their due date
    func groupedTasksByDate(tasks: [TaskModel]) {
        let calendar = Calendar.current
        let groupedTasks = Dictionary(grouping: tasks) { task in
            task.dueDate.map { calendar.startOfDay(for: $0) } ?? Date()
        }
        taskGroups = groupedTasks.sorted { $0.key < $1.key }
    }
    
    // Assign tasks to corresponding dates (even if no task exists for that date)
    func tasksInDates(tasks: [TaskModel]) {
        let dates = datesOfYear()
        taskGroups = dates.map { date in
            let tasksForDate = tasks.filter { task in
                let taskDate = Calendar.current.startOfDay(for: task.dueDate ?? Date())
                return taskDate == date
            }
            return (key: date, value: tasksForDate.isEmpty ? [] : tasksForDate)
        }
    }

    // Generate a list of dates for the current year (+/- 1 week)
    func datesOfYear() -> [Date] {
        let calendar = Calendar.current
        var dates = [Date]()
        
        let today = calendar.startOfDay(for: Date())
        
        // Show dates from today up to 360 days ahead
        guard let endDate = calendar.date(byAdding: .day, value: 360, to: today) else { return dates }

        var currentDate = today
        while currentDate <= endDate {
            dates.append(currentDate)
            // Move to the next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
    
    // MARK: - Task Management
    
    // Toggle task completion status and reload tasks
    func toggleTaskCompletion(task: TaskModel) {
        var editTask = task
        editTask.isCompleted.toggle()
        editTask.status = editTask.isCompleted ? .completed : .ready
        
        TaskManagerDB.shared.updateTask(task: editTask) { [weak self] error in
            if let error = error {
                self?.handleError("Error updating task: \(error.localizedDescription)")
            } else {
                self?.loadTasks()
            }
        }
    }
    
    // Placeholder for deleting a task (implement as needed)
    func deleteTask(at offsets: IndexSet) {
        // Implement task deletion logic here if required
    }
    
    // MARK: - Notifications
    
    // Observe task updates via notifications
    func registerObserveTaskInfo() {
        guard notificationObserver == nil else { return }
        
        notificationObserver = NotificationCenter.default.publisher(for: Notification.Name(Constants.taskNotificationInfo))
            .sink { [weak self] _ in
                print("TaskVM notification received")
                self?.loadTasks()
            }
    }
    
    // MARK: - Helper Methods
    
    // Handle and display error messages
    private func handleError(_ message: String) {
        errorMessage = message
        print(message)
    }
    
    deinit {
        notificationObserver?.cancel()
    }
}
