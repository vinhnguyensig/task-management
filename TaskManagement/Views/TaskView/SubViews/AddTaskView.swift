//
//  AddTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var startDate: Date = Date()
    @State private var dueDate: Date = Date().addingTimeInterval(60*60*24*2)
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory = .work
    @State private var selectedStatus: TaskStatus = .backlog
    
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").font(.headline)) {
                    TextField("Enter task title", text: $title)
                        .focused($isTitleFocused)
                        .onAppear {
                            self.isTitleFocused = true
                        }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    // Priority Picker
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized)
                                .tag(priority)
                        }
                    }

                    // Category Picker
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(TaskCategory.allCases, id: \.self) { category in
                            HStack {
                                category.icon
                                    .foregroundColor(category.color)
                                Text(category.rawValue.capitalized)
                            }
                            .tag(category)
                        }
                    }
                    
                    Picker("Status", selection: $selectedStatus) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            HStack {
                                status.icon
                                    .foregroundColor(status.color)
                                Text(status.rawValue.capitalized)
                            }
                            .tag(status)
                        }
                    }
                }

                // Add Task Button
                Button(action: {
                    viewModel.addTask(title: title, dueDate: dueDate, priority: selectedPriority, category: selectedCategory)
                    dismiss()
                }) {
                    Text("Add Task")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.borderless)
                .padding(.vertical)
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
