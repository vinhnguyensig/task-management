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
    @State private var toastMessage : String?
    @State private var isEnableAddReminder = false
    
    @FocusState private var isTitleFocused: Bool
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                taskDetailsSection
                if let error = errorMessage {
                    errorMessageView(error)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrowshape.down.circle")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addTask()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .overlay {
                if let message = toastMessage {
                    ToastView(message: message)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.9), value: true)
                }
            }
            .onReceive(viewModel.$addedTask, perform: { newTask in
                if let addedTask = newTask {
                    toastMessage = "Added Task"
                    if isEnableAddReminder {
                        viewModel.setReminder(task: addedTask)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation {
                            toastMessage = nil
                            title = ""
                            brief = ""
                            errorMessage = nil
                            isTitleFocused = true
                        }
                    }
                }
            })
            .onReceive(viewModel.$errorMessage, perform: { message in
                errorMessage = message
            })
        }
    }
    
    // MARK: - Task Details Section
    private var taskDetailsSection: some View {
        Section {
            taskTitleField
            briefDescriptionField
            dueDatePickerButton
            taskReminderButton
            priorityPicker
            categoryPicker
            statusPicker
        }
    }
    
    // MARK: - Components
    private var taskTitleField: some View {
        TextField("Enter task title", text: $title)
            .focused($isTitleFocused)
            .onAppear { self.isTitleFocused = true }
    }
    
    private var briefDescriptionField: some View {
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
    }
    
    private var dueDatePickerButton: some View {
        Button(action: { showDueDatePicker = true }) {
            HStack {
                Text("Due Date")
                Spacer()
                Image(systemName: "bell.badge.circle")
                Text("\(Utils.formattedDate(dueDate))")
            }
            .foregroundColor(.primary)
        }
        .sheet(isPresented: $showDueDatePicker) {
            DueDatePickerView(selectedDate: $dueDate)
                .presentationDetents([.large, .fraction(0.7)])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var taskReminderButton: some View {
        Button(action: {
            viewModel.requestionNotifictionAuthorization()
        }) {
            HStack {
                Text("Reminder")
                Spacer()
                Image(systemName: "bell.badge.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(isEnableAddReminder ? .blue : .gray)
            }
            .foregroundColor(.primary)
            .onReceive(viewModel.$notificationAuthorized, perform: { status in
                isEnableAddReminder = status
            })
        }
    }
    
    private var priorityPicker: some View {
        Picker("Priority", selection: $selectedPriority) {
            ForEach(TaskPriority.allCases, id: \.self) { priority in
                Text(priority.rawValue.capitalized)
                    .tag(priority)
            }
        }
    }
    
    private var categoryPicker: some View {
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
    }
    
    private var statusPicker: some View {
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
    
    private func errorMessageView(_ error: String) -> some View {
        Text(error)
            .foregroundColor(.red)
    }
    
    // MARK: - Add Task Logic
    private func addTask() {
        viewModel.addTask(
            title: title,
            dueDate: dueDate,
            priority: selectedPriority,
            category: selectedCategory,
            status: selectedStatus,
            brief: brief,
            detail: detail
        )
    }
}
