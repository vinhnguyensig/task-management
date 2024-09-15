//
//  TaskListView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskListView: View {
    var category: String?
    var status: String?
    var customTitle: String?
    
    @StateObject private var viewModel = TaskListViewModel()
    @State private var isTodayTasks = true
    @State private var showingSortOptions = false
    
    @State private var showConfetti = false
    @State private var confettiCounter = 0
    
    var body: some View {
        NavigationStack {
            VStack {
                taskContent
            }
            .navigationTitle(navigationTitle())
            .onAppear {
                viewModel.fetchTasks(category: category, isTodayTasks: isTodayTasks, status: status)
            }
            .toolbar {
                filterMenu
                sortMenu
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .confettiCannon(counter: $confettiCounter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
        }
    }
    
    // MARK: - Subviews
    
    private var taskContent: some View {
        Group {
            if viewModel.tasks.isEmpty {
                EmptyTaskView()
            } else {
                taskListView
                Spacer()
            }
        }
    }
    
    private var taskListView: some View {
        List {
            ForEach(viewModel.tasks) { task in
                TaskRowView(task: task,
                            onToggleComplete: { task in
                                if !task.isCompleted {
                                    confettiCounter += 1
                                }
                                viewModel.toggleTaskCompletion(task: task)
                            },
                            onTaskTapped: { task in
                                viewModel.registerObserveTaskInfo()
                            })
                .applyTaskRowStyle()
            }
            .onDelete(perform: viewModel.deleteTask)
            .onMove(perform: viewModel.moveTask)
        }
        .listStyle(.plain)
        .listRowSpacing(8)
        .background(Color(UIColor.systemBackground))
    }


    private func navigationTitle() -> String {
        if let catTitle = category {
            return catTitle
        } else if let title = customTitle {
            return title
        }
        return "Tasks for Today"
    }
    
    private var filterMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                // Filter by Status
                Section(header: Text("Filter")) {
                    Button(action: {
                        viewModel.currentFilter = .all
                        viewModel.fetchTasks()
                    }) {
                        Label("Show All", systemImage: viewModel.currentFilter == .all ? "checkmark" : "")
                    }
                    
                    Button(action: {
                        viewModel.currentFilter = .inProgress
                        viewModel.fetchTasks(status: TaskStatus.inProgress.rawValue)
                    }) {
                        Label("In Progress", systemImage: viewModel.currentFilter == .inProgress ? "checkmark" : "")
                    }
                    
                    Button(action: {
                        viewModel.currentFilter = .completed
                        viewModel.fetchTasks(status: TaskStatus.completed.rawValue)
                    }) {
                        Label("Completed", systemImage: viewModel.currentFilter == .completed ? "checkmark" : "")
                    }
                    
                    Button(action: {
                        viewModel.currentFilter = .backlog
                        viewModel.fetchTasks(status: TaskStatus.backlog.rawValue)
                    }) {
                        Label("Backlog", systemImage: viewModel.currentFilter == .backlog ? "checkmark" : "")
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
            }
        }
    }
    
    private var sortMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                sortOrderButton
                sortByCompletedButton
                sortByCreatedButton
                sortByPositionButton
            } label: {
                Image(systemName: "arrow.up.arrow.down.circle")
                    .font(.title2)
            }
        }
    }
    
    private var sortOrderButton: some View {
        Button(action: {
            viewModel.toggleSortOrder()
        }) {
            HStack {
                Text("Sort Order")
                Spacer()
                Image(systemName: viewModel.sortOrder == .ascending ? "arrow.up" : "arrow.down")
            }
        }
    }
    
    private var sortByPositionButton: some View {
        Button(action: {
            viewModel.toggleSortCriteria(.position)
        }) {
            HStack {
                Text("Sort by Position")
                Spacer()
                Image(systemName: viewModel.sortCriteria == .position ? "checkmark" : "")
            }
        }
    }
    
    private var sortByCompletedButton: some View {
        Button(action: {
            viewModel.toggleSortCriteria(.status)
        }) {
            HStack {
                Text("Sort by Status")
                Spacer()
                Image(systemName: viewModel.sortCriteria == .status ? "checkmark" : "")
            }
        }
    }
    
    private var sortByCreatedButton: some View {
        Button(action: {
            viewModel.toggleSortCriteria(.creationDate)
        }) {
            HStack {
                Text("Sort by Date Created")
                Spacer()
                Image(systemName: viewModel.sortCriteria == .creationDate ? "checkmark" : "")
            }
        }
    }
}
