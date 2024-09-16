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
    @StateObject var viewModel: TaskDetailsViewModel
    @ObservedObject var editViewModel: TaskEditViewModel
    
    @State private var isAddingSubTask = false
    @State private var title: String = ""
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        VStack {
            subtasksSection
            subTaskInputSection
            if !isAddingSubTask {
                addSubTaskButton
            }
        }
        .onAppear {
            viewModel.loadSubtasks(parentId: task.id)
        }
    }
    
    var subtasksSection: some View {
        List {
            ForEach(viewModel.subtasks) { sTask in
                Text(sTask.title)
                    .foregroundStyle(.primary)
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .background(Color(UIColor.systemBackground))
        }
    }
    
    var subTaskInputSection: some View {
        Group {
            if isAddingSubTask {
                TextField("Enter sub-task name", text: $title)
                    .focused($isTitleFocused)
                    .onAppear { isTitleFocused = true }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            saveButton
                        }
                    }
                    .submitLabel(.done)
                    .onSubmit {
                        if !title.isEmpty {
                            addSubTask()
                        }
                    }
                    .onReceive(editViewModel.$addedTask, perform: { newTask in
                        if let subtask = newTask {
                            viewModel.addSubTask(subTask: subtask)
                            print("added task title = ", subtask.title)
                            title = ""
                        }
                    })
            }
        }
        .padding(8)
    }
    
    var addSubTaskButton: some View {
        Button {
            isAddingSubTask = true
        } label: {
            Label("Add Subtask", systemImage: "plus.rectangle")
                .foregroundColor(.blue)
        }
    }
    
    private var saveButton: some View {
        Button("Add") {
            HapticManager.shared.triggerImpactFeedback(style: .medium)
            addSubTask()
        }
        .disabled(title.isEmpty)
    }
    
    private func addSubTask() {
        editViewModel.addSubtask(title: title, dueDate: task.dueDate, parentId: task.id)
    }
}
