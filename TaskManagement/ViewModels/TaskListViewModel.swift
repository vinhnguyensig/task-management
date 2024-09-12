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
    
    // Published properties for observing in the UI
    @Published var tasks: [Task] = []
    @Published var filterTasks: [Task] = []
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var sortOrder: SortOrder = .descending
    @Published var sortCriteria: SortCriteria = .creationDate
    
    var isTodayTask = true
    var isFilter = false
    
    private var currentCategory: String?
    private var notificationObserver: AnyCancellable?
    
    enum SortOrder {
        case ascending
        case descending
    }
    
    enum SortCriteria {
        case position
        case creationDate
    }
    
    // MARK: - Initialization
    init() {
        registerObserveTaskInfo()
    }
    
    // MARK: - Task Management Methods
    
    func fetchTasks(category: String? = nil, isTodayTasks: Bool = false) {
        let fetchMethod: (Result<[Task], Error>) -> Void = { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasks = self?.sortTasks(loadedTasks) ?? []
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
        isFilter = false
        if let category = category {
            currentCategory = category
            TaskManagerDB.shared.fetchTasks(by: category, completion: fetchMethod)
        } else if isTodayTasks {
            isTodayTask = true
            TaskManagerDB.shared.fetchTodayTasks(completion: fetchMethod)
        } else {
            TaskManagerDB.shared.getAllTasks(completion: fetchMethod)
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        for offset in offsets {
            let task = tasks[offset]
            TaskManagerDB.shared.deleteTask(task: task) { [weak self] error in
                if let error = error {
                    self?.errorMessage = "Error deleting task: \(error.localizedDescription)"
                    print(self?.errorMessage ?? "Unknown error")
                } else {
                    self?.tasks.remove(at: offset) // Remove from the local list after deletion
                }
            }
        }
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        // Move the tasks in the local array
        tasks.move(fromOffsets: source, toOffset: destination)
        
        // Update the positions of tasks in the local array
        for (index, _) in tasks.enumerated() {
            tasks[index].position = index + 1
        }
        
        // Save the updated positions to Realm
        TaskManagerDB.shared.updateTaskPositions(tasks) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error updating task positions: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    func toggleTaskCompletion(task: Task) {
        var editTask = task
        editTask.isCompleted.toggle()
        editTask.status = editTask.isCompleted ? TaskStatus.completed : TaskStatus.ready
        
        TaskManagerDB.shared.updateTask(task: editTask) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error updating task: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            } else {
                // Fetch tasks only if update succeeds
                self?.fetchTasks(category: self?.currentCategory, isTodayTasks: self?.isTodayTask ?? true)
            }
        }
    }
    
    // MARK: - Sorting
    
    func sortTasks(_ tasks: [Task]) -> [Task] {
        switch sortCriteria {
        case .position:
            return sortOrder == .ascending
            ? tasks.sorted { $0.position < $1.position }
            : tasks.sorted { $0.position > $1.position }
        case .creationDate:
            return sortOrder == .ascending
            ? tasks.sorted { $0.createdAt < $1.createdAt }
            : tasks.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    func toggleSortCriteria() {
        sortCriteria = (sortCriteria == .position) ? .creationDate : .position
        tasks = sortTasks(tasks)
    }
    
    func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
        tasks = sortTasks(tasks)
    }
    
    // MARK: - Filtering, Searching, and Refreshing
    
    func filteredTasks(by category: TaskCategory?) -> [Task] {
        return tasks.filter { task in
            (category == nil || task.category == category) &&
            (searchQuery.isEmpty || task.title.lowercased().contains(searchQuery.lowercased()))
        }
    }
    
    func refreshTasks() {
        fetchTasks()
    }
    
    func searchTasks(query: String) {
        searchQuery = query
        tasks = filteredTasks(by: nil)
    }
    
    func applyFilter(status: TaskStatus? = nil, priority: TaskPriority? = nil, isCompleted: Bool? = nil) {
        isFilter = false
        filterTasks = tasks.filter { task in
            var statusMatches = true
            var priorityMatches = true
            var isCompletedMatches = true
            
            if let status = status {
                statusMatches = task.status == status
                isFilter = true
            }
            
            if let priority = priority {
                priorityMatches = task.priority == priority
                isFilter = true
            }
            
            if let isCompleted = isCompleted {
                isCompletedMatches = task.isCompleted == isCompleted
                isFilter = true
            }
            return statusMatches && priorityMatches && isCompletedMatches
        }
    }
    
    // MARK: - Register Notification
    
    func registerObserveTaskInfo() {
        if notificationObserver == nil {
            notificationObserver = NotificationCenter.default.publisher(for: Notification.Name(Constants.taskNotificationInfo))
                .sink { [weak self] notification in
                    print("TaskListViewModel notification received")
                    if let _ = notification.userInfo {
                        if let category = self?.currentCategory {
                            self?.fetchTasks(category: category)
                        } else if self?.isTodayTask == true {
                            self?.fetchTasks(isTodayTasks: true)
                        } else {
                            self?.fetchTasks()
                        }
                    }
                }
        }
    }
    
    deinit {
        notificationObserver?.cancel()
        notificationObserver = nil
    }
}
