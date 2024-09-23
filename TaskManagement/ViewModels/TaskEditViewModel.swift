//
//  TaskEditViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import Combine

@MainActor
class TaskEditViewModel: ObservableObject {
    private var taskManager: TaskManagerDBProtocol
    
    @Published var addedTask: TaskModel?
    @Published var updatedTask: TaskModel?
    @Published var taskAIDetail: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isGenerateSuccess: Bool = false
    
    var isShouldPostNotify: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(taskManager: TaskManagerDBProtocol = TaskManagerDB.shared) {
        self.taskManager = taskManager
    }
    
    // MARK: - Task Operations
    
    func addTask(title: String, startDate: Date? = nil, dueDate: Date? = nil, priority: TaskPriority = .medium, category: TaskCategory = .others, status: TaskStatus = .backlog, brief: String? = nil, detail: String? = nil, position: Int = 1, isCompleted: Bool = false) {
        let newTask = TaskModel(title: title,
                                startDate: startDate,
                                dueDate: dueDate,
                                estimateHour: nil,
                                priority: priority,
                                category: category,
                                status: status,
                                brief: brief,
                                detail: detail,
                                assignees: [],
                                isCompleted: isCompleted,
                                position: position,
                                attachments: [])
        
        taskManager.createTask(task: newTask) { [weak self] error in
            self?.handleMainAsync {
                if let error = error {
                    self?.errorMessage = "Error adding task: \(error.localizedDescription)"
                    self?.logError(self?.errorMessage)
                } else {
                    self?.addedTask = newTask
                    self?.isShouldPostNotify = true
                    ShareService.shared.currentCategory = category.rawValue
                }
            }
        }
    }
    
    func updateTask(id: String, title: String, startDate: Date? = nil, dueDate: Date? = nil, priority: TaskPriority = .medium, category: TaskCategory = .others, status: TaskStatus = .backlog, brief: String? = nil, detail: String? = nil, position: Int = 1, isCompleted: Bool = false, parentId: String? = nil) {
        
        let editTask = TaskModel(id: id,
                                 title: title,
                                 startDate: startDate,
                                 dueDate: dueDate,
                                 estimateHour: nil,
                                 priority: priority,
                                 category: category,
                                 status: status,
                                 brief: brief,
                                 detail: detail,
                                 assignees: [],
                                 isCompleted: isCompleted,
                                 position: position,
                                 attachments: [],
                                 parentId: parentId)
        updateTask(editTask: editTask)
    }
    
    func updateTask(editTask: TaskModel) {
        taskManager.updateTask(task: editTask) { [weak self] error in
            self?.handleMainAsync {
                if let error = error {
                    self?.errorMessage = "Error updating task: \(error.localizedDescription)"
                    self?.logError(self?.errorMessage)
                } else {
                    self?.updatedTask = editTask
                    self?.isShouldPostNotify = true
                }
            }
        }
    }
    
    func updateTaskProgress(editTask: TaskModel) {
        taskManager.updateTask(task: editTask) { [weak self] error in
            self?.isShouldPostNotify = true
        }
    }
    
    func deleteTask(subtask: TaskModel) {
        taskManager.deleteTask(task: subtask) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error deleting task: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Subtasks
    
    func addSubtask(title: String, dueDate: Date? = nil, priority: TaskPriority = .medium, category: TaskCategory = .others, status: TaskStatus = .backlog, brief: String? = nil, detail: String? = nil, position: Int = 1, isCompleted: Bool = false, parentId: String) {
        let newTask = TaskModel(title: title,
                                dueDate: dueDate,
                                priority: priority,
                                category: category,
                                status: status,
                                brief: brief,
                                detail: detail,
                                isCompleted: isCompleted,
                                position: position,
                                parentId: parentId)
        
        taskManager.createTask(task: newTask) { [weak self] error in
            self?.handleMainAsync {
                if let error = error {
                    self?.errorMessage = "Error adding subtask: \(error.localizedDescription)"
                    self?.logError(self?.errorMessage)
                } else {
                    self?.addedTask = newTask
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func handleMainAsync(_ block: @escaping () -> Void) {
        DispatchQueue.main.async {
            block()
        }
    }
    
    private func logError(_ message: String?) {
        if let message = message {
            print(message)
        }
    }
}
