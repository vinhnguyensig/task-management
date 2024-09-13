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
    @Published var taskGroups: [(key: Date, value: [Task])] = []
   // @Published var selectedDate: Date?
    @Published var errorMessage: String?
    
    var isSelectedDate = false
    var isSelectedToday = false
    
    private var notificationObserver: AnyCancellable?
    
    init() {
        registerObserveTaskInfo()
        loadTasks()
    }
    
    func loadTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasksInDates(tasks: loadedTasks)
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    func groupedTasksByDate(tasks: [Task]) {
        let calendar = Calendar.current
        let groupedTasks = Dictionary(grouping: tasks) { task in
            task.dueDate.map { calendar.startOfDay(for: $0) } ?? Date()
        }
        taskGroups = groupedTasks.sorted { $0.key < $1.key }
    }
    
    func tasksInDates(tasks: [Task]) {
        let dates = datesOfYear()
        var groupDates: [(key: Date, value: [Task])] = []
        
        for date in dates {
            // Filter tasks for the specific date
            let tasksForDate = tasks.filter { task in
                let taskDate = Calendar.current.startOfDay(for: task.dueDate ?? Date())
                return taskDate == date
            }
            
            if !tasksForDate.isEmpty {
                groupDates.append((key: date, value: tasksForDate))
            } else {
                groupDates.append((key: date, value: [Task]()))
            }
        }
        
        taskGroups = groupDates
    }

    func datesOfYear() -> [Date] {
        let calendar = Calendar.current
        var dates = [Date]()
        
        // Show +/- 1 week from current date
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: 0, to: today),
              let endDate = calendar.date(byAdding: .day, value: 360, to: today) else {
            return dates
        }

        var currentDate = startDate
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
    
    func deleteTask(at offsets: IndexSet) {
    }
    
    func toggleTaskCompletion(task: Task) {
        var editTask = task
        editTask.isCompleted.toggle()
        editTask.status = editTask.isCompleted ? TaskStatus.completed : TaskStatus.ready
        
        TaskManagerDB.shared.updateTask(task: editTask) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error updating task: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            } else {
                self?.loadTasks()
            }
        }
    }
    
    func registerObserveTaskInfo() {
        if notificationObserver == nil {
            notificationObserver = NotificationCenter.default.publisher(for: Notification.Name(Constants.taskNotificationInfo))
                .sink { [weak self] notification in
                    print("TaskVM notification received")
                    if let _ = notification.userInfo {
                        self?.loadTasks()
                    }
                }
        }
    }
}
