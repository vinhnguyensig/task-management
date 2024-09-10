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
    @Published var errorMessage: String?
    
    var anyCancleables = Set<AnyCancellable>()
    
    func addTask(title: String, startDate: Date? = nil, dueDate: Date? = nil, priority: TaskPriority = .medium, category: TaskCategory = .others, status: TaskStatus = .backlog, brief: String? = nil, detail: String? = nil, position: Int = 1, isCompleted: Bool = false) {
        let newTask = Task(title: title,
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
            if let error = error {
                self?.errorMessage = "Error adding task: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    func setReminder() {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.$isAuthorized
            .dropFirst()
            .sink { status in
                print("authorize status = ", status)
            }
            .store(in: &anyCancleables)
        NotificationManager.shared.$errorMessage
            .dropFirst()
            .sink { [weak self] message in
                self?.errorMessage = message
            }
            .store(in: &anyCancleables)
    }
}
