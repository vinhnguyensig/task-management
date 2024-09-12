//
//  AddTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct AddTaskView: View {
    var task: Task?
    
    @StateObject var viewModel = TaskEditViewModel()
    @StateObject var reminderViewModel = TaskReminderViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var brief: String = ""
    @State private var detail: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory = .work
    @State private var selectedStatus: TaskStatus = .ready
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
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if task == nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "arrowshape.down.circle")
                                .foregroundColor(.gray)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let editTask = task {
                        Button("Update") {
                            HapticManager.shared.triggerImpactFeedback(style: .medium)
                            updateTask(editTask: editTask)
                        }
                        .disabled(title.isEmpty)
                    } else {
                        Button("Add") {
                            HapticManager.shared.triggerImpactFeedback(style: .medium)
                            addTask()
                        }
                        .disabled(title.isEmpty)
                    }
                }
            }
            .onAppear {
                if let editTask = task {
                    title = editTask.title
                    if let desc = editTask.brief {
                        brief = desc
                    }
                    if let dd = editTask.dueDate {
                        dueDate = dd
                    }
                    selectedPriority = editTask.priority
                    selectedCategory = editTask.category
                    selectedStatus = editTask.status
                    if let dt = editTask.detail {
                        detail = dt
                    }
                }
            }
            .overlay {
                if let message = toastMessage {
                    ToastView(message: message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.5), value: true )
                }
            }
            .onReceive(viewModel.$addedTask, perform: { newTask in
                if let addedTask = newTask {
                    toastMessage = "Added Task"
                    if isEnableAddReminder {
                        reminderViewModel.setReminder(task: addedTask)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
            .onReceive(viewModel.$updatedTask, perform: { editTask in
                if let uptask = editTask {
                    toastMessage = "Updated Task"
                    if isEnableAddReminder {
                        reminderViewModel.setReminder(task: uptask)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        toastMessage = nil
                        NotificationCenter.default.post(name: Notification.Name(Constants.taskNotificationInfo), object: nil, userInfo: ["task": uptask])
                        dismiss()
                    }
                }
            })
            .onReceive(viewModel.$errorMessage, perform: { message in
                errorMessage = message
            })
            .onDisappear {
                if viewModel.isShouldPostNotify {
                    viewModel.isShouldPostNotify = false
                    NotificationCenter.default.post(name: Notification.Name(Constants.taskNotificationInfo), object: nil, userInfo: ["reload": true])
                }
            }
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
            
            if let _ = task {
               detailDesField
                Spacer()
            }
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
    
    private var detailDesField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Task Detail", systemImage: "doc.text")
                .foregroundColor(.secondary)
            
            TextEditor(text: $detail)
                .frame(minHeight: 100, maxHeight: 160)
                .padding(1)
                .background(Color(.white))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            
            Button(action: {
                // Action to generate detailed description
            }) {
                Label("Generate task detail with AI", systemImage: "wand.and.stars")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var dueDatePickerButton: some View {
        Button(action: {
            HapticManager.shared.triggerImpactFeedback(style: .medium)
            showDueDatePicker = true
        }) {
            HStack {
                Text("Due Date")
                Spacer()
                Image(systemName: "calendar")
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
            HapticManager.shared.triggerImpactFeedback(style: .medium)
            if let editTask = task {
                if isEnableAddReminder {
                    reminderViewModel.removeReminder(id: editTask.id)
                    isEnableAddReminder = false
                } else {
                    reminderViewModel.setReminder(task: editTask)
                }
            } else {
                reminderViewModel.requestionNotifictionAuthorization()
            }
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
            .onReceive(reminderViewModel.$notificationAuthorized, perform: { status in
                isEnableAddReminder = status
            })
            .onAppear {
                if let editTask = task {
                    isEnableAddReminder = reminderViewModel.isSetReminder(id: editTask.id)
                }
            }
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
                    Image(systemName: category.icon)
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
                    Image(systemName: status.icon)
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
    
    private func updateTask(editTask: Task) {
        viewModel.updateTask(
            id: editTask.id,
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
