//
//  TaskDetailView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskDetailView: View {
    @State var task: TaskModel
    @StateObject private var viewModel = TaskDetailsViewModel()
    @StateObject private var reminderViewModel = TaskReminderViewModel()
    @StateObject private var editViewModel = TaskEditViewModel()
    
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
            ScrollView(showsIndicators: false, content: {
                VStack(alignment: .leading, spacing: 16) {
                    taskHeader
                    taskMetaInfo
                    Divider()
                    taskDatesSection
                    Divider()
                    briefDescriptionSection
                    detailedDescriptionSection
                    SubTaskView(task: task, viewModel: viewModel, editViewModel: editViewModel)
                }
            })
            .frame(maxWidth: .infinity)
            .padding()
            .onAppear(perform: setupView)
            .onDisappear{ handleDisappear() }
            .navigationTitle("")
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
        if editViewModel.isShouldPostNotify {
            editViewModel.isShouldPostNotify = false
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
                HapticManager.shared.triggerImpactFeedback(style: .light)
                isSelectedPriority = true
            }
            .actionSheet(isPresented: $isSelectedPriority) {
                ActionSheet(
                    title: Text("Select Status"),
                    buttons: TaskPriority.allCases.map { priority in
                            .default(Text(priority.rawValue)) {
                                selectedPriority = priority
                                task.priority = priority
                                editViewModel.updateTask(editTask: task)
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
            HapticManager.shared.triggerImpactFeedback(style: .light)
            isSelectedCategory = true
        }
        .actionSheet(isPresented: $isSelectedCategory) {
            ActionSheet(
                title: Text("Select Status"),
                buttons: TaskCategory.allCases.map { category in
                        .default(Text(category.rawValue)) {
                            selectedCategory = category
                            task.category = category
                            editViewModel.updateTask(editTask: task)
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
            HapticManager.shared.triggerImpactFeedback(style: .light)
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
                            editViewModel.updateTask(editTask: task)
                        }
                } + [.cancel()]
            )
        }
    }
    
    var taskDatesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let dueDate = task.dueDate {
                dueDateView(dueDate)
                    .padding(.vertical, 8)
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
                descriptionSection(title: "Brief", text: brief, systemImage: "text.book.closed", minHeight: 60, maxHeight: 100)
            }
        }
        .padding(.vertical, 8)
    }
    
    var detailedDescriptionSection: some View {
        Group {
            if !detail.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    descriptionSection(title: "Task Detail", text: detail, systemImage: "doc.text", minHeight: 100)
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
                .background(Color(UIColor.systemBackground))
                .cornerRadius(8)
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
    
    func updateTaskInfo(info: TaskModel?) {
        if let nTask = info {
            task = nTask
        }
    }
    
    func toggleReminder() {
        if isAddReminder {
            reminderViewModel.removeReminder(id: task.id)
        } else {
            reminderViewModel.addReminder(task: task)
        }
        isAddReminder.toggle()
    }
}
