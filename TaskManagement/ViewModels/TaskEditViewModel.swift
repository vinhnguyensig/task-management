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
    
    var chatAIViewModel: ChatAIViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
    }
    
    private func initChatViewModel() {
        if chatAIViewModel == nil {
            chatAIViewModel = ChatAIViewModel()
        }
    }
    
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
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error adding task: \(error.localizedDescription)"
                    print(self?.errorMessage ?? "Unknown error")
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
        TaskManagerDB.shared.updateTask(task: editTask) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error update task: \(error.localizedDescription)"
                    print(self?.errorMessage ?? "Unknown error")
                } else {
                    self?.updatedTask = editTask
                    self?.isShouldPostNotify = true
                }
            }
        }
    }
    
    func fetchTaskDetailSuggestion(task: TaskModel) {
        initChatViewModel()
        guard let viewModel = chatAIViewModel else { return }
        let prompt = createTaskPrompt(task: task)
        Task {
            await viewModel.fetchChatCompletion(singleMessage: prompt)
            self.isLoading = true
            viewModel.$responseMessage
                .sink {[weak self] result in
                    self?.isLoading = false
                    let responseDetail = Utils.clearSpecialChar(text: result)
                    DispatchQueue.main.async {
                        self?.taskAIDetail = responseDetail
                    }
                }
                .store(in: &cancellables)
            
            viewModel.$errorMessage
                .sink {[weak self] message in
                    self?.isLoading = false
                    if let msg = message {
                        DispatchQueue.main.async {
                            self?.errorMessage = msg
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }

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
    
}
