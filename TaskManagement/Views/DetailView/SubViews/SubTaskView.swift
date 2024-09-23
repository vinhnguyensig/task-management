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
    @Binding var isExpandedDetail: Bool
    
    @StateObject private var generatorViewModel = GenerateTaskViewModel()
    @State private var isAddingSubTask = false
    @State private var isGeneratingSubTask = false
    @State private var isExpanded = true
    @State private var isShowDetail = false
    @State private var title: String = ""
    @State private var subtasks = [TaskModel]()
    
    @State private var showConfetti = false
    @State private var confettiCounter = 0
    
    @FocusState private var isTitleFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            subtasksSection
            if !isGeneratingSubTask {
                if isAddingSubTask {
                    subTaskInputSection
                } else {
                    addSubTaskButton
                }
            } else {
                VStack {
                   ProgressView()
                   Text("Generating Sub-Tasks...")
                       .font(.subheadline)
                       .foregroundColor(.orange)
                    Spacer()
               }
               .frame(maxWidth: .infinity)
               .multilineTextAlignment(.center)
            }
        }
        .onAppear(perform: loadSubtasks)
        .onReceive(editViewModel.$addedTask, perform: handleAddedTask)
        .onReceive(viewModel.$subtasks, perform: handleLoadedSubtasks)
        .onReceive(editViewModel.$updatedTask, perform: handleUpdatedTask)
        .onReceive(generatorViewModel.$isGenerateSuccess, perform: { status in
            if status {
                isGeneratingSubTask = false
                isExpanded = true
                loadSubtasks()
            }
        })
        .sheet(isPresented: $isShowDetail, content: {
            if let sTask = viewModel.selectedSubtask {
                TaskDetailView(task: sTask)
                    .presentationDetents([.medium, .large])
            }
        })
        .confettiCannon(counter: $confettiCounter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
    }
    
    private var subtasksSection: some View {
        Group {
            if !subtasks.isEmpty {
                headerSection
                if isExpanded {
                    subtasksListView
                } else {
                    LineProgressView(progress: task.progress, color: TaskProgress.getProgressColor(progress: task.progress))
                        .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            Label("Sub Tasks", systemImage: "list.dash.header.rectangle")
                .foregroundColor(.secondary)
            Text(getCompletedTaskRatio())
                .foregroundStyle(.blue)
            Spacer()
            Button(action: toggleExpanded) {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .padding()
            }
        }
    }
    
    private var subtasksListView: some View {
        List {
            ForEach(subtasks, id: \.id) { sTask in
                HStack {
                    CheckmarkButton(isCompleted: sTask.isCompleted) {
                        toggleCompletion(for: sTask)
                    }
                    
                    Text(sTask.title)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .accessibilityLabel("Task title: \(sTask.title)")
                        .onTapGesture {
                            viewModel.selectedSubtask = sTask
                            isShowDetail = true
                        }
                }
                .padding(.vertical, 4)
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
            .onDelete(perform: { indexSet in
                indexSet.forEach { index in
                    let stask = subtasks[index]
                    editViewModel.deleteTask(subtask: stask)
                    subtasks.remove(at: index)
                }
            })
            .onMove(perform: { indices, newOffset in
            })
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .listRowSpacing(2)
        .frame(height: CGFloat(subtasks.count * 55))
        .padding(.horizontal)
    }
    
    
    private var subTaskInputSection: some View {
        HStack {
            TextField("Enter subtask name", text: $title)
                .focused($isTitleFocused)
                .onAppear { isTitleFocused = true }
                .submitLabel(.done)
                .onSubmit(addSubTaskIfNotEmpty)
                .padding(8)
            Spacer()
            Button("Add", action: addSubTaskIfNotEmpty)
                .foregroundColor(.blue)
                .disabled(title.isEmpty)
        }
    }
    
    private var addSubTaskButton: some View {
        HStack {
            Button(action: { isAddingSubTask = true }) {
                Label("Add Subtask", systemImage: "plus.rectangle")
                    .foregroundColor(.blue)
            }
            Spacer()
            Button(action: {
                isGeneratingSubTask = true
                generatorViewModel.generateSubTasks(task: task)
            }) {
                Label("Generate Sub-Tasks", systemImage: "sparkles")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func loadSubtasks() {
        viewModel.loadSubtasks(parentId: task.id)
    }
    
    private func handleAddedTask(_ result: TaskModel?) {
        if result != nil {
            viewModel.loadSubtasks(parentId: task.id)
        }
    }
    
    private func handleLoadedSubtasks(_ result: [TaskModel]?) {
        if let tasks = result {
            title = ""
            subtasks = tasks
            updateProgress()
            if subtasks.count > 0 {
                isExpandedDetail = false
                isTitleFocused = true
            }
        }
    }
    
    private func handleUpdatedTask(_ result: TaskModel?) {
        if result != nil {
            updateProgress()
        }
    }
    
    private func toggleCompletion(for task: TaskModel) {
        if let index = subtasks.firstIndex(where: { $0.id == task.id }) {
            subtasks[index].isCompleted.toggle()
            var updatedTask = task
            updatedTask.isCompleted = subtasks[index].isCompleted
            updatedTask.status = .completed
            editViewModel.updateTask(id: task.id ,title: "Test Edit task")
        }
    }
    
    private func toggleExpanded() {
        withAnimation {
            isExpanded.toggle()
        }
    }
    
    private func addSubTaskIfNotEmpty() {
        if !title.isEmpty {
            addSubTask()
            isTitleFocused = false
        }
    }
    
    private func getCompletedTaskRatio() -> String {
        let completedCount = subtasks.filter { $0.isCompleted }.count
        return "\(completedCount)/\(subtasks.count)"
    }
    
    private func updateProgress() {
        let completedCount = subtasks.filter { $0.isCompleted }.count
        let totalCount = subtasks.count
        let progress = totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0
        if progress != task.progress {
            task.progress = progress
            editViewModel.updateTaskProgress(editTask: task)
        }
    }
    
    private func addSubTask() {
        editViewModel.addSubtask(title: title, dueDate: task.dueDate, parentId: task.id)
    }
}
