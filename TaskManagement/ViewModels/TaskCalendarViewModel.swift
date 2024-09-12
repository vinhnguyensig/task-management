//
//  TaskCalendarViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import Foundation

@MainActor
class TaskCalendarViewModel: ObservableObject {
    @Published var tasks: [Task] = []
   // @Published var selectedDate: Date?
    @Published var errorMessage: String?
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasks = loadedTasks
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
}
