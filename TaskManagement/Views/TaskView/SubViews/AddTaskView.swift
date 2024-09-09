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
    @State private var dueDate: Date = Date()
    @State private var selectedPriority: TaskPriority = .medium
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details").font(.headline)) {
                    TextField("Enter task title", text: $title)
                        .focused($isTitleFocused)
                        .onAppear{
                            self.isTitleFocused = true
                        }

                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)

                    // Priority Picker
                    Picker("Priority", selection: $selectedPriority) {
                        ForEach(TaskPriority.allCases, id: \.self) { priority in
                            Text(priority.rawValue.capitalized).tag(priority)
                        }
                    }
                }
                
                // Add Task Button
                Button(action: {
                    viewModel.addTask(title: title, dueDate: dueDate, priority: selectedPriority)
                    dismiss() // Dismiss the sheet
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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
