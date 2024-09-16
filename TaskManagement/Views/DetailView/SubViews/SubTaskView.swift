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
            }
        })
    }
    
    private var subtasksSection: some View {
        Group {
            if !subtasks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Sub Tasks ", systemImage: "list.dash.header.rectangle")
                            .foregroundColor(.secondary)
                        subtasksView
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private var subtasksView: some View {
        ScrollView {
            ForEach(subtasks) { sTask in
                HStack {
                    Circle()
                        .fill(sTask.isCompleted ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                    
                    Text(sTask.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Priority indicator
                    if sTask.priority == .high {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(.vertical, 8)
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
                                isAddingSubTask = false
                                isTitleFocused = false
                            }
                        }
                        .padding(8)
                    Spacer()
                    Button("Add") {
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
    
    private func addSubTask() {
        editViewModel.addSubtask(title: title, dueDate: task.dueDate, parentId: task.id)
    }
}
