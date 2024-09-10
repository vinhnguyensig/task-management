import Foundation

@MainActor
class TaskListViewModel: ObservableObject {
    
    @Published var tasks: [Task] = []
    @Published var errorMessage: String?
    @Published var searchQuery: String = ""
    @Published var sortOrder: SortOrder = .descending
    @Published var sortByPosition: Bool = false
    
    enum SortOrder {
        case ascending
        case descending
    }
    
    init() {
    }
    
    // MARK: - Task Management Methods
    
    func fetchTasks(category: String?) {
        if let category = category {
            loadTasksByCategory(category: category)
        } else {
            loadTasks()
        }
    }
    
    func loadTasksByCategory(category: String) {
        TaskManagerDB.shared.fetchTasks(by: category) { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasks = self?.sortTasks(loadedTasks) ?? []
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
        }
    }
    
    func loadTasks() {
        TaskManagerDB.shared.getAllTasks { [weak self] result in
            switch result {
            case .success(let loadedTasks):
                self?.tasks = self?.sortTasks(loadedTasks) ?? []
            case .failure(let error):
                self?.errorMessage = "Failed to load tasks: \(error.localizedDescription)"
                print(self?.errorMessage ?? "Unknown error")
            }
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
    
    // MARK: - Sorting by Position and Due Date
    
    func sortTasks(_ tasks: [Task]) -> [Task] {
        if sortByPosition {
            return sortOrder == .ascending
                ? tasks.sorted { $0.position < $1.position }
                : tasks.sorted { $0.position > $1.position }
        } else {
            return sortOrder == .ascending
                ? tasks.sorted { $0.createdAt < $1.createdAt }
                : tasks.sorted { $0.createdAt > $1.createdAt }
        }
    }
    
    func toggleSortOrder() {
        sortOrder = (sortOrder == .ascending) ? .descending : .ascending
        tasks = sortTasks(tasks)
    }
    
    func toggleSortByPosition() {
        sortByPosition.toggle()
        tasks = sortTasks(tasks)
    }
    
    // MARK: - Filtering, Searching, and Refreshing
    
    func filteredTasks(by category: TaskCategory?) -> [Task] {
        let filtered = tasks.filter { task in
            (category == nil || task.category == category) &&
            (searchQuery.isEmpty || task.title.lowercased().contains(searchQuery.lowercased()))
        }
        return filtered
    }
    
    func refreshTasks() {
        loadTasks()
    }
    
    func searchTasks(query: String) {
        searchQuery = query
    }
}
