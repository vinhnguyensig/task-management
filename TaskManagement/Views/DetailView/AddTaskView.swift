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
    
    @State private var title = ""
    @State private var brief = ""
    @State private var detail = ""
    @State private var dueDate = Date()
    @State private var selectedPriority: TaskPriority = .medium
    @State private var selectedCategory: TaskCategory = .work
    @State private var selectedStatus: TaskStatus = .ready
    @State private var showDueDatePicker = false
    @State private var toastMessage: String?
    @State private var isEnableAddReminder = false
    
    @FocusState private var isTitleFocused: Bool
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                taskDetailsSection
                if let errorMessage {
                    errorMessageView(errorMessage)
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    if task == nil {
                        dismissButton
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .onAppear(perform: setupView)
            .overlay(toastOverlay)
            .onReceive(viewModel.$addedTask, perform: handleNewTask)
            .onReceive(viewModel.$updatedTask, perform: handleUpdatedTask)
            .onReceive(viewModel.$errorMessage) { message in
                errorMessage = message
            }
            .onDisappear(perform: handleDisappear)
        }
    }

    // MARK: - Subviews
    private var taskDetailsSection: some View {
        Section {
            taskTitleField
            briefDescriptionField
            dueDatePickerButton
            taskReminderButton
            priorityPicker
            categoryPicker
            statusPicker
            if task != nil { detailDescriptionField }
        }
    }

    private var dismissButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "arrowshape.down.circle")
                .foregroundColor(.gray)
        }
    }

    private var saveButton: some View {
        Button(task == nil ? "Add" : "Update") {
            HapticManager.shared.triggerImpactFeedback(style: .medium)
            task == nil ? addTask() : updateTask(editTask: task!)
        }
        .disabled(title.isEmpty)
    }

    private var toastOverlay: some View {
        Group {
            if let toastMessage {
                ToastView(message: toastMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.5), value: true)
            }
        }
    }

    // MARK: - Components
    private var taskTitleField: some View {
        TextField("Enter task title", text: $title)
            .focused($isTitleFocused)
            .onAppear { isTitleFocused = true }
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

    private var detailDescriptionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Task Detail", systemImage: "doc.text")
                .foregroundColor(.secondary)
            TextEditor(text: $detail)
                .frame(minHeight: 100, maxHeight: 160)
                .padding(1)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            Button(action: {
                // Action for AI task detail generation
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
            showDueDatePicker.toggle()
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
        Button(action: toggleReminder) {
            HStack {
                Text("Reminder")
                Spacer()
                Image(systemName: "bell.badge.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(isEnableAddReminder ? .blue : .gray)
            }
            .foregroundColor(.primary)
            .onReceive(reminderViewModel.$notificationAuthorized) { isEnableAddReminder = $0 }
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
                    if let _ = task {
                        HStack {
                            Image(systemName: status.icon)
                                .foregroundColor(status.color)
                            Text(status.rawValue.capitalized)
                        }
                        .tag(status)
                    } else if status == .backlog || status == .ready || status == .inProgress {
                        HStack {
                            Image(systemName: status.icon)
                                .foregroundColor(status.color)
                            Text(status.rawValue.capitalized)
                        }
                        .tag(status)
                    }
                }
            }
        }

    // MARK: - Task Action Logic
    private func addTask() {
        viewModel.addTask(
            title: title,
            dueDate: dueDate,
            priority: selectedPriority,
            category: selectedCategory,
            status: selectedStatus,
            brief: brief,
            detail: detail,
            isCompleted: isTaskCompleted
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
            detail: detail,
            isCompleted: isTaskCompleted
        )
    }

    private var isTaskCompleted: Bool {
        [.completed, .inReview, .done].contains(selectedStatus)
    }

    // MARK: - Handlers
    private func setupView() {
        if let editTask = task {
            title = editTask.title
            brief = editTask.brief ?? ""
            detail = editTask.detail ?? ""
            dueDate = editTask.dueDate ?? Date()
            selectedPriority = editTask.priority
            selectedCategory = editTask.category
            selectedStatus = editTask.status
        } else {
            dueDate = ShareService.shared.currentSelectedDate ?? Date()
            selectedCategory = TaskCategory(rawValue: ShareService.shared.currentCategory ?? "work") ?? .work
        }
    }

    private func handleNewTask(newTask: Task?) {
        guard let addedTask = newTask else { return }
        toastMessage = "Added Task"
        if isEnableAddReminder {
            reminderViewModel.setReminder(task: addedTask)
        }
        clearForm()
    }

    private func handleUpdatedTask(editTask: Task?) {
        guard let uptask = editTask else { return }
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

    private func handleDisappear() {
        if viewModel.isShouldPostNotify {
            viewModel.isShouldPostNotify = false
            NotificationCenter.default.post(name: Notification.Name(Constants.taskNotificationInfo), object: nil, userInfo: ["reload": true])
        }
    }

    private func clearForm() {
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

    private func toggleReminder() {
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
    }

    private func errorMessageView(_ error: String) -> some View {
        Text(error).foregroundColor(.red)
    }
}
