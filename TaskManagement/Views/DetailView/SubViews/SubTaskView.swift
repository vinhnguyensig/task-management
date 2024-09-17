//
//  SubTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 16/9/24.
//

//
//  SubTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 16/9/24.
//

import SwiftUI

struct SubTaskView: View {
    @State var task: TaskModel
    @ObservedObject var viewModel: TaskDetailsViewModel
    @ObservedObject var editViewModel: TaskEditViewModel
    
    @State private var isAddingSubTask = false
    @State private var isExpanded = true
    @State private var title: String = ""
    @State private var subtasks = [TaskModel]()
   
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, content: {
            subtasksSection
            subTaskInputSection
            if !isAddingSubTask {
                addSubTaskButton
            }
            Spacer()
        })
        .onAppear {
            viewModel.loadSubtasks(parentId: task.id)
        }
        .onReceive(editViewModel.$addedTask, perform: { result in
            if let _ = result {
                viewModel.loadSubtasks(parentId: task.id)
            }
        })
        .onReceive(viewModel.$subtasks, perform: { result in
            if let tasks = result {
                title = ""
                subtasks = tasks
                isTitleFocused = true
                updateProgress()
            }
        })
        .onReceive(editViewModel.$updatedTask, perform: { result in
            if let _ = result {
                updateProgress()
            }
        })
    }
    
    private var subtasksSection: some View {
        Group {
            if !subtasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Sub Tasks ", systemImage: "list.dash.header.rectangle")
                                .foregroundColor(.secondary)
                            Text("\(getCompleteNumber())")
                                .foregroundStyle(.blue)
                            Spacer()
                            Button {
                                updateProgress()
                                withAnimation {
                                    isExpanded.toggle()
                                }
                            } label: {
                                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                    .padding()
                            }
                        }
                        if isExpanded {
                            subtasksView
                        } else {
                            LineProgressView(progress: task.progress, color: TaskProgress.getProgressColor(progress: task.progress))
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var subtasksView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(subtasks, id: \.id) { sTask in
                    HStack(alignment: .center) {
                        CheckmarkButton(isCompleted: sTask.isCompleted) {
                            toggleCompletion(for: sTask)
                        }

                        Text(sTask.title)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .accessibilityLabel("Task title: \(sTask.title)")
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
    
    private var subTaskInputSection: some View {
        Group {
            if isAddingSubTask {
                HStack {
                    TextField("Enter subtask name", text: $title)
                        .focused($isTitleFocused)
                        .onAppear { isTitleFocused = true }
                        .submitLabel(.done)
                        .onSubmit {
                            if !title.isEmpty {
                                addSubTask()
                            }
                            isAddingSubTask = false
                            isTitleFocused = false
                        }
                        .padding(8)
                    Spacer()
                    Button("Add") {
                        isTitleFocused = false
                        HapticManager.shared.triggerImpactFeedback(style: .medium)
                        addSubTask()
                    }
                    .foregroundColor(.blue)
                    .disabled(title.isEmpty)
                }
                Spacer()
            }
        }
    }
    
    
    private var addSubTaskButton: some View {
        Button {
            isAddingSubTask = true
        } label: {
            Label("Add Subtask", systemImage: "plus.rectangle")
                .foregroundColor(.blue)
        }
    }
    
    private func toggleCompletion(for task: TaskModel) {
        if let index = subtasks.firstIndex(where: { $0.id == task.id }) {
            subtasks[index].isCompleted.toggle()
            var editTask = task
            editTask.isCompleted = subtasks[index].isCompleted
            editViewModel.updateTask(editTask: editTask)
            
        }
    }
    
    private func getCompletedAndTotalCount() -> (completed: Int, total: Int) {
        let completed = subtasks.filter { $0.isCompleted }.count
        let total = subtasks.count
        return (completed, total)
    }

    private func getCompleteNumber() -> String {
        let (completed, total) = getCompletedAndTotalCount()
        return String(format: "%d/%d", completed, total)
    }

    private func updateProgress() {
        let (completed, total) = getCompletedAndTotalCount()
        let progress = total > 0 ? Double(completed) / Double(total) : 0
        if progress != task.progress {
            task.progress = progress
            print("completed = \(completed) total = \(total) updateProgress = ", progress)
            editViewModel.updateTaskProgress(editTask: task)
        }
    }
    
    private func addSubTask() {
        editViewModel.addSubtask(title: title, dueDate: task.dueDate, parentId: task.id)
    }
}
