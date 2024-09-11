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
    @State private var showDueDatePicker = false
    
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
                        if brief.isEmpty {
                            Text("Brief Description")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                        }
                        TextEditor(text: $brief)
                            .frame(height: 60)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        
                    }
                    
                    // Button to open Due Date Picker
                    Button(action: {
                        showDueDatePicker = true
                    }) {
                        HStack {
                            Text("Due Date")
                            Spacer()
                            Image(systemName: "bell.badge.circle")
                            Text("\(Utils.formattedDate(dueDate))")
                        }
                        .foregroundColor(.primary)
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .sheet(isPresented: $showDueDatePicker) {
                        DueDatePickerView(selectedDate: $dueDate)
                            .presentationDetents([.large, .fraction(0.7)])
                            .presentationDragIndicator(.visible)
                    }
                    
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
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrowshape.down.circle")
                            .foregroundColor(.gray)
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        
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
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}
