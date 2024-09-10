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
    
    func setReminder(task: Task) {
        NotificationManager.shared.requestAuthorization()
        NotificationManager.shared.$isAuthorized
            .dropFirst()
            .sink { [weak self] status in
                if status {
                    if let dueDate = task.dueDate {
                        NotificationManager.shared.scheduleNotification(id: task.id, title: task.title, body: task.brief ?? "", date: dueDate)
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.errorMessage = "Notification permission denied"
                    }
                }
            }
            .store(in: &anyCancleables)
        
        NotificationManager.shared.$isSetNotify
            .dropFirst()
            .sink { status in
                if status {
                    UserDefaultsManager.save(value: status, forKey: task.id)
                }
            }
            .store(in: &anyCancleables)
        
        NotificationManager.shared.$errorMessage
            .dropFirst()
            .sink { [weak self] message in
                DispatchQueue.main.async {
                    self?.errorMessage = message
                }
            }
            .store(in: &anyCancleables)
    }
    
    func removeReminder(id: String) {
        NotificationManager.shared.cancelNotification(identifier: id)
        UserDefaultsManager.remove(forKey: id)
    }
    
    func isSetReminder(id: String) -> Bool {
        if let _ = UserDefaultsManager.get(forKey: id) {
            return true
        }
        return false
    }
}
