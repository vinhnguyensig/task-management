//
//  TaskListView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showingAddTaskView = false
    @State private var showingSortOptions = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.tasks.isEmpty {
                    EmptyTaskView()
                } else {
                    List {
                        ForEach(viewModel.filteredTasks(by: nil)) { task in
                            NavigationLink(destination: TaskDetailView(task: task)) {
                                TaskRowView(task: task)
                            }
                        }
                        .onDelete(perform: viewModel.deleteTask)
                        .onMove(perform: viewModel.moveTask)
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            viewModel.toggleSortOrder()
                        }) {
                            HStack {
                                Text("Sort Order")
                                Spacer()
                                Image(systemName: viewModel.sortOrder == .ascending ? "arrow.up" : "arrow.down")
                            }
                        }
                        
                        Button(action: {
                            viewModel.toggleSortByPosition()
                        }) {
                            HStack {
                                Text("Sort by Position")
                                Spacer()
                                Image(systemName: viewModel.sortByPosition ? "list.number" : "list.bullet")
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTaskView = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(viewModel: viewModel)
            }
            .searchable(text: $viewModel.searchQuery)
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}
