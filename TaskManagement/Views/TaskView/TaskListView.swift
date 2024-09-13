//
//  TaskListView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskListView: View {
    var category: String?
    
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
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.automatic)
            .onAppear {
                viewModel.fetchTasks(category: category, isTodayTasks: isTodayTasks)
            }
            .toolbar {
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


    private var navigationTitle: String {
        category == nil ? "Tasks for Today" : category!
    }
    
    private var filterMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                // Filter by Status
                Section(header: Text("Filter")) {
                    Button(action: {
                        viewModel.applyFilter()
                    }) {
                        Label("Show All", systemImage: "list.bullet.clipboard")
                            .foregroundColor(viewModel.currentFilter == .all ? .blue : .primary)
                            .overlay(
                                viewModel.currentFilter == .all ? Image(systemName: "checkmark").foregroundColor(.blue) : nil,
                                alignment: .trailing
                            )
                    }
                    
                    Button(action: {
                        viewModel.applyFilter(isCompleted: false)
                    }) {
                        Label("In Progress", systemImage: "figure.run")
                            .foregroundColor(viewModel.currentFilter == .inProgress ? .blue : .primary)
                            .overlay(
                                viewModel.currentFilter == .inProgress ? Image(systemName: "checkmark").foregroundColor(.blue) : nil,
                                alignment: .trailing
                            )
                    }
                    
                    Button(action: {
                        viewModel.applyFilter(isCompleted: true)
                    }) {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .foregroundColor(viewModel.currentFilter == .completed ? .blue : .primary)
                            .overlay(
                                viewModel.currentFilter == .completed ? Image(systemName: "checkmark").foregroundColor(.blue) : nil,
                                alignment: .trailing
                            )
                    }
                    
                    Button(action: {
                        viewModel.applyFilter(status: .backlog)
                    }) {
                        Label("Backlog", systemImage: "tray.fill")
                            .foregroundColor(viewModel.currentFilter == .backlog ? .blue : .primary)
                            .overlay(
                                viewModel.currentFilter == .backlog ? Image(systemName: "checkmark").foregroundColor(.blue) : nil,
                                alignment: .trailing
                            )
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
