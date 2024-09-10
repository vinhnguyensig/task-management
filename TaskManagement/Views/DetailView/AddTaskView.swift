//
//  AddTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct AddTaskView: View {
    @StateObject var viewModel = TaskEditViewModel()
    
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var brief: String = ""
    @State private var detail: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory = .work
    @State private var selectedStatus: TaskStatus = .inProgress
    
    @FocusState private var isTitleFocused: Bool
    @State private var validationError: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Task Details").font(.headline)) {
                    // Task Title
                    TextField("Enter task title", text: $title)
                        .focused($isTitleFocused)
                        .onAppear {
                            self.isTitleFocused = true
                        }
                    
                    VStack(alignment: .leading) {
                        Text("Brief Description")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        TextEditor(text: $brief)
                            .frame(height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                    }
                    
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
                    
                    // Status Picker
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

                if let error = validationError {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                // Add Task Button
                Button(action: {
                    if validateTask() {
                        viewModel.addTask(
                            title: title,
                            dueDate: dueDate,
                            priority: selectedPriority,
                            category: selectedCategory,
                            status: selectedStatus,
                            brief: brief,
                            detail: detail
                        )
                        dismiss()
                    }
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

    // Validation function
    private func validateTask() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationError = "Task title cannot be empty."
            return false
        }

        validationError = nil
        return true
    }
}
