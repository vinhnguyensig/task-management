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
            .searchable(text: $viewModel.searchQuery)
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
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
            ForEach(viewModel.filteredTasks(by: nil)) { task in
                TaskRowView(task: task, onToggleComplete: { task in
                    viewModel.toggleTaskCompletion(task: task)
                }, onTaskTapped: { task in
                    viewModel.registerObserveTaskInfo()
                })
            }
            .onDelete(perform: viewModel.deleteTask)
            .onMove(perform: viewModel.moveTask)
        }
    }
    
    private var navigationTitle: String {
        category == nil ? "Tasks for Today" : category!
    }
    
    private var sortMenu: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
                sortOrderButton
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
            viewModel.toggleSortCriteria()
        }) {
            HStack {
                Text("Sort by Position")
                Spacer()
                Image(systemName: viewModel.sortCriteria == .position ? "list.number" : "list.bullet")
            }
        }
    }
}
