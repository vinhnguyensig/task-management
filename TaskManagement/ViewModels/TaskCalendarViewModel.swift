//
//  TaskCalendarViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import Foundation

@MainActor
class TaskCalendarViewModel: ObservableObject {
    @Published var taskGroups: [(key: Date, value: [Task])] = []
   // @Published var selectedDate: Date?
    @Published var errorMessage: String?
    
    var isSelectedDate = false
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                //self?.groupedTasksByDate(tasks: loadedTasks)
                self?.tasksInDate(tasks: loadedTasks)
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
    
    func tasksInDate(tasks: [Task]) {
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
        guard let startDate = calendar.date(byAdding: .day, value: -2, to: today),
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

}
