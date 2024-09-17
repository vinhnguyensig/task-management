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
    
    // MARK: - Task Management Methods
    
    func fetchTasks(category: String? = nil, isTodayTasks: Bool = false, status: String? = nil) {
        let fetchMethod: (Result<[TaskModel], Error>) -> Void = { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasks = self?.sortTasks(loadedTasks) ?? []
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
        
        if let category = category {
            currentCategory = category
            ShareService.shared.currentCategory = category
            TaskManagerDB.shared.fetchTasks(by: category, completion: fetchMethod)
        } else if let status = status {
            TaskManagerDB.shared.fetchTasks(status: status, isToday: isTodayTasks, category: currentCategory, completion: fetchMethod)
        } else if isTodayTasks {
            isTodayTask = true
            ShareService.shared.currentCategory = nil
            ShareService.shared.currentSelectedDate = Date()
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
                    self?.tasks.remove(at: offset)
                }
            }
        }
    }
    
    func moveTask(from source: IndexSet, to destination: Int) {
        tasks.move(fromOffsets: source, toOffset: destination)
        for (index, _) in tasks.enumerated() {
            tasks[index].position = index + 1
        }
        TaskManagerDB.shared.updateTaskPositions(tasks) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error updating task positions: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    func toggleTaskCompletion(task: TaskModel) {
        var editTask = task
        editTask.isCompleted.toggle()
        editTask.status = editTask.isCompleted ? TaskStatus.completed : TaskStatus.ready
        
        TaskManagerDB.shared.updateTask(task: editTask) { [weak self] error in
            if let error = error {
                self?.errorMessage = "Error updating task: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            } else {
                self?.fetchTasks(category: self?.currentCategory, isTodayTasks: self?.isTodayTask ?? true)
            }
        }
    }
    
    // MARK: - Sorting
    
    func sortTasks(_ tasks: [TaskModel]) -> [TaskModel] {
        switch sortCriteria {
        case .position:
            return sortOrder == .ascending
            ? tasks.sorted { $0.position < $1.position }
            : tasks.sorted { $0.position > $1.position }
        case .creationDate:
            return sortOrder == .ascending
            ? tasks.sorted { $0.createdAt < $1.createdAt }
            : tasks.sorted { $0.createdAt > $1.createdAt }
        case .status:
            return tasks.sorted {
                  sortOrder == .ascending ? !$0.isCompleted && $1.isCompleted : $0.isCompleted && !$1.isCompleted
              }
        }
    }
    
    func toggleSortCriteria(_ sortBy: SortCriteria) {
        sortCriteria = sortBy
        tasks = sortTasks(tasks)
    }
    
    func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
        tasks = sortTasks(tasks)
    }
    
    // MARK: - Filtering, Searching, and Refreshing
    
    func filteredTasks(by category: TaskCategory?) -> [TaskModel] {
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
