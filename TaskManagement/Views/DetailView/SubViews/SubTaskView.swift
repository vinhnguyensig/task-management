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
                            Spacer()
                            Button {
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
                            LineProgressView(progress: 0.6, color: TaskProgress.getProgressColor(progress: 0.6))
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
                ForEach(subtasks) { sTask in
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
            print("editTask title = \(editTask.title) complete = \(editTask.isCompleted) parentid = \(editTask.parentId)")
            editViewModel.updateTask(editTask: editTask)
        }
    }
    
    private func addSubTask() {
        editViewModel.addSubtask(title: title, dueDate: task.dueDate, parentId: task.id)
    }
}
