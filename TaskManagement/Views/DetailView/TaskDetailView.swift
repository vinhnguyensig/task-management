//
//  TaskDetailView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskDetailView: View {
    @State var task: Task
    @StateObject var viewModel = TaskDetailsViewModel()
    @StateObject var reminderViewModel = TaskReminderViewModel()
    @StateObject private var editviewModel = TaskEditViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var brief: String = ""
    @State private var detail: String = ""
    @State private var isAddReminder = false
    @State private var isNavigateEdit = false
    
    @State private var selectedStatus = TaskStatus.ready
    @State private var isSelectedStatus = false
    
    @State private var selectedCategory = TaskCategory.work
    @State private var isSelectedCategory = false
    
    @State private var selectedPriority = TaskPriority.medium
    @State private var isSelectedPriority = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    taskHeader
                    taskMetaInfo
                    Divider()
                    taskDatesSection
                    Divider()
                    briefDescriptionSection
                    detailedDescriptionSection
                }
                .padding()
            }
            .frame(maxWidth: .infinity)
            .onAppear(perform: setupView)
            .onDisappear{ handleDisappear() }
            .navigationTitle(task.status.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrowshape.down.circle")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        HapticManager.shared.triggerImpactFeedback(style: .medium)
                        viewModel.registerObserveTaskInfo()
                        isNavigateEdit = true
                    }
                }
            }
            .navigationDestination(isPresented: $isNavigateEdit) {
                AddTaskView(task: task)
            }
            .onReceive(viewModel.$task, perform: updateTaskInfo)
        }
    }
    
    private func handleDisappear() {
        if editviewModel.isShouldPostNotify {
            editviewModel.isShouldPostNotify = false
            NotificationCenter.default.post(name: Notification.Name(Constants.taskNotificationInfo), object: nil, userInfo: ["reload": true])
        }
    }
}

// MARK: - View Components

private extension TaskDetailView {
    
    var taskHeader: some View {
        Text(task.title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 4)
            .accessibilityAddTraits(.isHeader)
    }
    
    var taskMetaInfo: some View {
        HStack(alignment: .center, spacing: 8) {
            taskPriorityLabel
            Spacer()
            taskCategoryLabel
            Spacer()
            taskStatusLabel
        }
        .padding(.vertical, 8)
    }
    
    var taskPriorityLabel: some View {
        Label(task.priority.rawValue.capitalized, systemImage: "flag.fill")
            .padding(4)
            .background(task.priority.color)
            .cornerRadius(6)
            .foregroundColor(.white)
            .font(.subheadline)
            .accessibilityLabel("Priority: \(task.priority.rawValue)")
            .onTapGesture {
               isSelectedPriority = true
            }
            .actionSheet(isPresented: $isSelectedPriority) {
                ActionSheet(
                        title: Text("Select Status"),
                        buttons: TaskPriority.allCases.map { priority in
                            .default(Text(priority.rawValue)) {
                                selectedPriority = priority
                                task.priority = priority
                                editviewModel.updateTask(editTask: task)
                            }
                        } + [.cancel()]
                    )
            }
    }
    
    var taskCategoryLabel: some View {
        HStack {
            Image(systemName: task.category.icon)
                .foregroundColor(task.category.color)
            Text(task.category.rawValue.capitalized)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.leading, 2)
        }
        .onTapGesture {
           isSelectedCategory = true
        }
        .actionSheet(isPresented: $isSelectedCategory) {
            ActionSheet(
                    title: Text("Select Status"),
                    buttons: TaskCategory.allCases.map { category in
                        .default(Text(category.rawValue)) {
                            selectedCategory = category
                            task.category = category
                            editviewModel.updateTask(editTask: task)
                        }
                    } + [.cancel()]
                )
        }
    }
    
    var taskStatusLabel: some View {
        HStack {
            Image(systemName: task.status.icon)
                .foregroundColor(task.status.color)
            Text(task.status.rawValue.capitalized)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .onTapGesture {
           isSelectedStatus = true
        }
        .actionSheet(isPresented: $isSelectedStatus) {
            ActionSheet(
                    title: Text("Select Status"),
                    buttons: TaskStatus.allCases.map { status in
                        .default(Text(status.rawValue)) {
                            selectedStatus = status
                            task.status = status
                            task.isCompleted = isTaskCompleted
                            editviewModel.updateTask(editTask: task)
                        }
                    } + [.cancel()]
                )
        }
    }
    
    var taskDatesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let dueDate = task.dueDate {
                dueDateView(dueDate)
            }
            reminderSection
        }
        .padding(.vertical, 8)
    }
    
    @ViewBuilder
    func dueDateView(_ dueDate: Date) -> some View {
        HStack {
            Label("Due Date", systemImage: "calendar.badge.exclamationmark")
                .font(.headline)
                .foregroundColor(.secondary)
            Spacer()
            Text(Utils.formattedDate(dueDate))
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .accessibilityElement(children: .combine)
    }
    
    var reminderSection: some View {
        HStack {
            Text("Reminder")
                .foregroundColor(.secondary)
            Spacer()
            reminderButton
        }
    }
    
    var reminderButton: some View {
        Button {
            HapticManager.shared.triggerImpactFeedback(style: .medium)
            toggleReminder()
        } label: {
            Image(systemName: "bell.badge.circle.fill")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundColor(isAddReminder ? .blue : .gray)
        }
        .onReceive(reminderViewModel.$notificationAuthorized) { status in
            isAddReminder = status
        }
    }
    
    var briefDescriptionSection: some View {
        Group {
            if !brief.isEmpty {
                descriptionSection(title: "Brief Description", text: brief, systemImage: "text.book.closed", minHeight: 60, maxHeight: 100)
            }
        }
        .padding(.vertical, 8)
    }
    
    var detailedDescriptionSection: some View {
        Group {
            if !detail.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    descriptionSection(title: "Task Detail", text: detail, systemImage: "doc.text", minHeight: 100)
                    generateDetailButton
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    func descriptionSection(title: String, text: String, systemImage: String, minHeight: CGFloat, maxHeight: CGFloat = .infinity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .foregroundColor(.secondary)
            Text(text)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .padding(1)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
    }
    
    var generateDetailButton: some View {
        Button(action: {
            // Action to generate detailed description
        }) {
            Label("Generate task detail with AI", systemImage: "wand.and.stars")
                .foregroundColor(.blue)
        }
    }
    
    private var isTaskCompleted: Bool {
        [.completed, .inReview, .done].contains(selectedStatus)
    }
}

// MARK: - Helper Methods

private extension TaskDetailView {
    func setupView() {
        brief = task.brief ?? ""
        detail = task.detail ?? ""
        selectedStatus = task.status
        isAddReminder = reminderViewModel.isSetReminder(id: task.id)
    }
    
    func updateTaskInfo(info: Task?) {
        if let nTask = info {
            task = nTask
        }
    }
    
    func toggleReminder() {
        if isAddReminder {
            reminderViewModel.removeReminder(id: task.id)
            isAddReminder = false
        } else {
            reminderViewModel.setReminder(task: task)
        }
    }
}
