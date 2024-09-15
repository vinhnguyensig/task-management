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
    @Published var isLoading: Bool = false
    @Published var isGenerateSuccess: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    let viewModel = ChatAIViewModel()
    
    init() {
        bindData()
    }
    
    func bindData() {
        viewModel.$responseMessage
            .dropFirst()
            .sink {[weak self] result in
                DispatchQueue.main.async {
                    self?.isGenerateSuccess = true
                    self?.isLoading = false
                }
                print("result = ", result)
                self?.processTaskList(text: result)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .dropFirst()
            .sink {[weak self] message in
                if let msg = message {
                    DispatchQueue.main.async {
                        self?.isGenerateSuccess = false
                        self?.isLoading = false
                        self?.errorMessage = msg
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func generateTasks(requirement: String) {
        if let template = getTemplate() {
            self.isLoading = true
            var prompt = "Please create task list from requirement."
            prompt = prompt + "Output is json format like this"
            prompt = prompt + template
            prompt = prompt + "Requirement: " + requirement
            print("prompt = ", prompt)
            Task {
                await viewModel.fetchChatCompletion(singleMessage: prompt)
                
            }
        } else {
            handleFailGenerateTask()
        }
    }
    
    private func handleFailGenerateTask() {
        DispatchQueue.main.async {
            self.isGenerateSuccess = false
            self.isLoading = false
            self.errorMessage = "Please try to write more detail requirment"
        }
    }
    
   private func processTaskList(text: String) {
        let pattern = #"(?<=```json)[\s\S]*?(?=```)"#
        if let jsonRange = text.range(of: pattern, options: .regularExpression) {
            let jsonString = String(text[jsonRange])
            if let jsonData = jsonString.data(using: .utf8) {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                        var tasks = [TaskModel]()
                        var position = 1
                        for item in jsonArray {
                            if let title = item["title"] as? String {
                                let brief = item["brief"] as? String ?? ""
                                let detail = item["detail"] as? String ?? ""
                                position = position + 1
                                let task = TaskModel(title: title, brief: brief, detail: detail, position: position)
                                tasks.append(task)
                            }
                        }
                        if tasks.count > 0 {
                            for task in tasks {
                                print("task title = ", task.title)
                                TaskManagerDB.shared.createTask(task: task) { error in
                                    if let _ = error {
                                        print("can not save task ", task.title)
                                    }
                                }
                            }
                        } else {
                            handleFailGenerateTask()
                        }
                    }
                } catch {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                    handleFailGenerateTask()
                }
            } else {
                print("Failed to parse jsonData")
                handleFailGenerateTask()
            }
        } else {
            print("Failed to parse jsonRange")
            handleFailGenerateTask()
        }
    }
    
    private func getTemplate() -> String? {
        if let path = Bundle.main.path(forResource: "task-template", ofType: "json") {
            do {
                let fileContents = try String(contentsOfFile: path, encoding: .utf8)
                return fileContents
            } catch {
                print("Error reading file as String: \(error)")
                handleFailGenerateTask()
            }
        } else {
            print("File not found")
            handleFailGenerateTask()
        }
        return nil
    }
}
