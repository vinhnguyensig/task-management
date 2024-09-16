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
    @Published var addedTask: TaskModel?
    @Published var updatedTask: TaskModel?
    @Published var taskAIDetail: String?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    
    var isShouldPostNotify: Bool = false
    
    lazy var chatAIViewModel: ChatAIViewModel? = ChatAIViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    init() {}

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
        
        TaskManagerDB.shared.createTask(task: newTask) { [weak self] error in
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
    
    func updateTask(id: String, title: String, startDate: Date? = nil, dueDate: Date? = nil, priority: TaskPriority = .medium, category: TaskCategory = .others, status: TaskStatus = .backlog, brief: String? = nil, detail: String? = nil, position: Int = 1, isCompleted: Bool = false) {
        
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
                                 attachments: [])
        updateTask(editTask: editTask)
    }
    
    func updateTask(editTask: TaskModel) {
        print("task progress = ", editTask.progress)
        TaskManagerDB.shared.updateTask(task: editTask) { [weak self] error in
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
        print("task progress = ", editTask.progress)
        TaskManagerDB.shared.updateTask(task: editTask) { [weak self] error in
            self?.isShouldPostNotify = true
        }
    }
    
    // MARK: - Task Suggestions
    
    func fetchTaskDetailSuggestion(task: TaskModel) {
        guard let viewModel = chatAIViewModel else { return }
        let prompt = createTaskPrompt(task: task)
        self.isLoading = true
        Task {
            await viewModel.fetchChatCompletion(singleMessage: prompt)
            
            Publishers.CombineLatest(viewModel.$responseMessage, viewModel.$errorMessage)
                .sink { [weak self] (response, error) in
                    self?.isLoading = false
                    if let errorMessage = error {
                        self?.handleMainAsync {
                            self?.errorMessage = errorMessage
                        }
                    } else {
                        let responseDetail = Utils.clearSpecialChar(text: response)
                        self?.handleMainAsync {
                            self?.taskAIDetail = responseDetail
                        }
                    }
                }
                .store(in: &cancellables)
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
        
        TaskManagerDB.shared.createTask(task: newTask) { [weak self] error in
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
    
    private func createTaskPrompt(task: TaskModel) -> String {
        var prompt = "Task: \(task.title)\n"
        
        if let dueDate = task.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            prompt += "Due Date: \(formatter.string(from: dueDate))\n"
        }
        
        prompt += "Priority: \(task.priority.rawValue.capitalized)\n"
        prompt += "Category: \(task.category.rawValue.capitalized)\n"
        prompt += "Status: \(task.status.rawValue.capitalized)\n"
        
        if let brief = task.brief, !brief.isEmpty {
            prompt += "Brief: \(brief)\n"
        }
        
        prompt += task.isCompleted ? "The task is completed.\n" : "The task is not completed yet.\n"
        prompt = Utils.clearSpecialChar(text: prompt)
        return prompt
    }

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
