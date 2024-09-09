//
//  TaskListViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation

@MainActor
class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var isAddingNewTask = false
    
    init() {
    }
    
    // MARK: - Task Management Methods
    
    func loadTasks() async {
        do {
            let loadedTasks = try await TaskManagerDB.shared.getAllTasks()
            tasks = loadedTasks
        } catch {
            print("Failed to load tasks: \(error)")
        }
    }
    
    func addTask(title: String, dueDate: Date? = nil, priority: TaskPriority = .medium, category: TaskCategory? = nil, description: String? = nil, isCompleted: Bool = false) async {
        let newTask = Task(title: title, dueDate: dueDate, priority: priority, category: category, description: description, isCompleted: isCompleted)
        
        
        do {
            try await TaskManagerDB.shared.createTask(task: newTask)
            tasks.append(newTask)
        } catch {
            print("Error adding task: \(error)")
        }
        
    }
    
    func deleteTask(at offsets: IndexSet) async {
        
        for offset in offsets {
            let task = tasks[offset]
            do {
                try await TaskManagerDB.shared.deleteTask(task: task)
            } catch {
                print("Error deleting task: \(error)")
            }
        }
        tasks.remove(atOffsets: offsets)
        
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        //update the tasks' order in persistent storage
    }
    
    // MARK: - Filtering and Sorting
    
    func filteredTasks(by category: TaskCategory?) -> [Task] {
        if let category = category {
            return tasks.filter { $0.category == category }
        } else {
            return tasks
        }
    }
}
