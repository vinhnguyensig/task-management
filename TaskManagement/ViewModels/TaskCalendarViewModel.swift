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
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.groupedTasksByDate(tasks: loadedTasks)
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
}
