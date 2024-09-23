//
//  TaskListViewModel.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import Combine

@MainActor
class TaskListViewModel: ObservableObject {
    
    // Published properties for UI binding
    @Published var tasks: [TaskModel] = []
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var sortOrder: SortOrder = .descending
    @Published var sortCriteria: SortCriteria = .creationDate
    @Published var currentFilter: TaskFilter = .all
    
    var isTodayTask = true
    var currentCategory: String?
    
    private var notificationObserver: AnyCancellable?
    
    enum SortOrder {
        case ascending
        case descending
    }
    
    enum SortCriteria {
        case position
        case creationDate
        case status
    }
    
    enum TaskFilter {
        case all
        case ready
        case inProgress
        case completed
        case backlog
    }
    
    // MARK: - Initialization
    init() {
        registerObserveTaskInfo()
    }
    
    // MARK: - Task Management
    
    // Fetch tasks based on filters (category, status, or today's tasks)
    func fetchTasks(category: String? = nil, isTodayTasks: Bool = false, status: String? = nil) {
        let fetchCompletion: (Result<[TaskModel], Error>) -> Void = { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasks = self?.sortTasks(loadedTasks) ?? []
            case .failure(let error):
                self?.handleError("Failed to load tasks: \(error.localizedDescription)")
            }
        }
        
        if let category = category {
            currentCategory = category
            ShareService.shared.currentCategory = category
            TaskManagerDB.shared.fetchTasks(by: category, completion: fetchCompletion)
        } else if let status = status {
            TaskManagerDB.shared.fetchTasks(status: status, isToday: isTodayTasks, category: currentCategory, completion: fetchCompletion)
        } else if isTodayTasks {
            isTodayTask = true
            ShareService.shared.currentCategory = nil
            ShareService.shared.currentSelectedDate = Date()
            TaskManagerDB.shared.fetchTodayTasks(completion: fetchCompletion)
        } else {
            TaskManagerDB.shared.getAllTasks(completion: fetchCompletion)
        }
    }
    
    // Delete task at specific offsets
    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { offset in
            let task = tasks[offset]
            TaskManagerDB.shared.deleteTask(task: task) { [weak self] error in
                if let error = error {
                    self?.handleError("Error deleting task: \(error.localizedDescription)")
                } else {
                    self?.tasks.remove(at: offset)
                }
            }
        }
    }
    
    // Move task and update positions
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        tasks.enumerated().forEach { index, _ in tasks[index].position = index + 1 }
        
        TaskManagerDB.shared.updateTaskPositions(tasks) { [weak self] error in
            if let error = error {
                self?.handleError("Error updating task positions: \(error.localizedDescription)")
            }
        }
    }
    
    // Toggle task completion status
    func toggleTaskCompletion(task: TaskModel) {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.status = updatedTask.isCompleted ? .completed : .ready
        
        TaskManagerDB.shared.updateTask(task: updatedTask) { [weak self] error in
            if let error = error {
                self?.handleError("Error updating task: \(error.localizedDescription)")
            } else {
                self?.fetchTasks(category: self?.currentCategory, isTodayTasks: self?.isTodayTask ?? true)
            }
        }
    }
    
    // MARK: - Sorting
    
    // Sort tasks based on selected criteria and order
    func sortTasks(_ tasks: [TaskModel]) -> [TaskModel] {
        switch sortCriteria {
        case .position:
            return tasks.sorted { sortOrder == .ascending ? $0.position < $1.position : $0.position > $1.position }
        case .creationDate:
            return tasks.sorted { sortOrder == .ascending ? $0.createdAt < $1.createdAt : $0.createdAt > $1.createdAt }
        case .status:
            return tasks.sorted { sortOrder == .ascending ? !$0.isCompleted && $1.isCompleted : $0.isCompleted && !$1.isCompleted }
        }
    }
    
    // Toggle sort criteria and apply sorting
    func toggleSortCriteria(_ sortBy: SortCriteria) {
        sortCriteria = sortBy
        tasks = sortTasks(tasks)
    }
    
    // Toggle sort order and apply sorting
    func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
        tasks = sortTasks(tasks)
    }
    
    // MARK: - Filtering, Searching, and Refreshing
    
    // Filter tasks by category and search query
    func filteredTasks(by category: TaskCategory?) -> [TaskModel] {
        tasks.filter { task in
            (category == nil || task.category == category) &&
            (searchQuery.isEmpty || task.title.lowercased().contains(searchQuery.lowercased()))
        }
    }
    
    // Refresh the task list
    func refreshTasks() {
        fetchTasks()
    }
    
    // Search tasks by query and update list
    func searchTasks(query: String) {
        searchQuery = query
        tasks = filteredTasks(by: nil)
    }
    
    // MARK: - Notification Handling
    
    // Observe task changes via notifications
    func registerObserveTaskInfo() {
        guard notificationObserver == nil else { return }
        
        notificationObserver = NotificationCenter.default.publisher(for: Notification.Name(Constants.taskNotificationInfo))
            .sink { [weak self] _ in
                print("TaskListViewModel notification received")
                if let category = self?.currentCategory {
                    self?.fetchTasks(category: category)
                } else if self?.isTodayTask == true {
                    self?.fetchTasks(isTodayTasks: true)
                } else {
                    self?.fetchTasks()
                }
            }
    }
    
    // MARK: - Helper Methods
    
    // Handle and display error messages
    private func handleError(_ message: String) {
        errorMessage = message
        print(message)
    }
    
    deinit {
        notificationObserver?.cancel()
    }
}
