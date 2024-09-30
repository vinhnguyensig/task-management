//
//  GenerateTaskViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 15/9/24.
//

import Foundation
import Combine

@MainActor
class GenerateTaskViewModel: ObservableObject {
    private var networkService: NetworkServiceProtocol
    
    @Published var responseMessage: String = ""
    @Published var isLoading: Bool = false
    @Published var isGenerateSuccess: Bool = false
    @Published var errorMessage: String?
    
    var parentTask: TaskModel?
    
    init(networkService: NetworkServiceProtocol = NetwordService.shared) {
        self.networkService = networkService
    }
    
    // Fetch task details based on a suggestion. Basically calling AI for help.
    func fetchTaskDetailSuggestion(task: TaskModel) {
        let prompt = createTaskPrompt(task: task)
        Task {
            if let response = await fetchChatCompletion(prompt) {
                updateResponseMessage(with: response)
            }
        }
    }
    
    // Generate tasks based on a requirement. Asking AI to do my job.
    func generateTasks(requirement: String) {
        guard let template = getTemplate() else {
            handleFailGenerateTask()
            return
        }
        
        let prompt = """
        Please create task list from requirement. Output is json format like this:
        \(template)
        Requirement: \(requirement)
        """
        
        isLoading = true
        Task {
            if let response = await fetchChatCompletion(prompt) {
                processTaskList(from: response)
            }
        }
    }
    
    // Generate subtasks from a given task. More work for AI, less for me.
    func generateSubTasks(task: TaskModel) {
        var requirement = task.title
        
        if let brief = task.brief { requirement += "Brief: " + brief }
        if let detail = task.detail { requirement += "Task Detail: " + detail }
        
        Task {
            await generateSubTasks(requirement: requirement, task: task)
        }
    }
    
    // Fetch completion from OpenAI. In other words, delegate thinking to AI.
    private func fetchChatCompletion(_ prompt: String) async -> String? {
        guard !prompt.isEmpty else {
            errorMessage = "Please enter a message to send."
            return nil
        }
        
        isLoading = true
        errorMessage = nil
        
        let userMessage = OpenAIMessage(role: "user", content: prompt)
        
        do {
            let result = try await networkService.fetchChat(messages: [userMessage])
            isLoading = false
            return result
        } catch {
            handleError(error)
            return nil
        }
    }
    
    // Generates subtasks but with extra steps. Let AI handle the dirty work.
    private func generateSubTasks(requirement: String, task: TaskModel) async {
        guard let template = getTemplate() else {
            handleFailGenerateTask()
            return
        }
        
        parentTask = task
        let prompt = """
        Please create sub tasks from main task in requirement. Output is json format like this:
        \(template)
        Requirement: \(requirement)
        """
        
        isLoading = true
        Task {
            if let response = await fetchChatCompletion(prompt) {
                processTaskList(from: response)
            }
        }
    }
    
    // Process a response that supposedly has a list of tasks. Hope AI got this right.
    private func processTaskList(from response: String) {
        let pattern = #"(?<=```json)[\s\S]*?(?=```)"#
        
        guard let jsonString = response.extract(usingPattern: pattern),
              let jsonData = jsonString.data(using: .utf8) else {
            handleFailGenerateTask()
            return
        }
        
        do {
            if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                handleTaskList(jsonArray)
            } else {
                handleFailGenerateTask()
            }
        } catch {
            print("Failed to parse JSON: \(error.localizedDescription)")
            handleFailGenerateTask()
        }
    }
    
    // Process a list of tasks one by one. More like automate saving, so I don’t have to.
    private func handleTaskList(_ jsonArray: [[String: Any]]) {
        var tasks = [TaskModel]()
        let reversedTasks = jsonArray.reversed()
        var position = 1
        let parentId = parentTask?.id
        
        for item in reversedTasks {
            if let title = item["title"] as? String {
                let brief = item["brief"] as? String ?? ""
                let detail = item["detail"] as? String ?? ""
                position += 1
                let task = TaskModel(title: title, brief: brief, detail: detail, position: position, parentId: parentId)
                tasks.append(task)
            }
        }
        
        if !tasks.isEmpty {
            saveTasks(tasks)
        } else {
            handleFailGenerateTask()
        }
    }
    
    // Recursively save tasks. The lazy way to handle lists.
    private func saveTasks(_ tasks: [TaskModel], index: Int = 0) {
        guard index < tasks.count else {
            completeTaskProcessing()
            return
        }
        
        let task = tasks[index]
        TaskManagerDB.shared.createTask(task: task) { [weak self] error in
            if error != nil {
                print("Could not save task: \(task.title)")
            }
            self?.saveTasks(tasks, index: index + 1)
        }
    }
    
    // Wrap up after saving tasks. Finally, something I can mark as done.
    private func completeTaskProcessing() {
        isGenerateSuccess = true
        isLoading = false
    }
    
    // Handle failure when task generation fails. It's not me, it's the AI.
    private func handleFailGenerateTask() {
        DispatchQueue.main.async {
            self.isGenerateSuccess = false
            self.isLoading = false
            self.errorMessage = "Please try to provide more detailed requirements."
        }
    }
    
    // Handle errors, because things do go wrong sometimes.
    private func handleError(_ error: Error) {
        isLoading = false
        if let networkError = error as? NetworkError {
            errorMessage = networkError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    // Get the task template. Hope the file exists.
    private func getTemplate() -> String? {
        guard let path = Bundle.main.path(forResource: "task-template", ofType: "json") else {
            print("Template file not found.")
            return nil
        }
        
        do {
            return try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            print("Error reading template: \(error)")
            return nil
        }
    }
    
    // Build a task prompt string. Formatting is boring, let’s automate it.
    private func createTaskPrompt(task: TaskModel) -> String {
        var prompt = """
        Task: \(task.title)\n
        Priority: \(task.priority.rawValue.capitalized)\n
        Category: \(task.category.rawValue.capitalized)\n
        Status: \(task.status.rawValue.capitalized)\n
        """
        
        if let dueDate = task.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            prompt += "Due Date: \(formatter.string(from: dueDate))\n"
        }
        
        if let brief = task.brief, !brief.isEmpty { prompt += "Brief: \(brief)\n" }
        
        prompt += task.isCompleted ? "The task is completed.\n" : "The task is not completed yet.\n"
        return Utils.clearSpecialChar(text: prompt)
    }
    
    // Update the response message, aka make it look like I did some work.
    private func updateResponseMessage(with response: String) {
        responseMessage = Utils.formatChatAIResponse(text: response)
    }
}

private extension String {
    // Regex to extract string. Yup, regex for the win.
    func extract(usingPattern pattern: String) -> String? {
        let range = self.range(of: pattern, options: .regularExpression)
        return range.map { String(self[$0]) }
    }
}
