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
    @State private var showingSortOptions = false
   
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.tasks.isEmpty {
                    EmptyTaskView()
                } else {
                    VStack {
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
                   
            }
            .navigationTitle(category == nil ? "Tasks": category!)
            .task {
                viewModel.fetchTasks(category: category)
            }
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
            }
            .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
                Alert(title: Text("Error"), message: Text(viewModel.errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}
