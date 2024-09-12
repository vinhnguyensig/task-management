//
//  TaskInprogressView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskInProgressView: View {
    @StateObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Section Title
            HStack {
                Text("In Progress")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("\(viewModel.tasksInProgress.count)")
                    .font(.callout)
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 16)
            
            // Horizontal Scroll View for tasks
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.tasksInProgress) { task in
                        TaskInProgress(
                            viewModel: viewModel,
                            task: task
                        )
                    }
                }
                .padding(.leading, 16)
                .padding(.vertical, 5)
            }
        }
        .padding(.vertical)
        .onAppear {
            viewModel.loadProgressTask()
        }
    }
}

struct TaskInProgress: View {
    @ObservedObject var viewModel: DashboardViewModel
    let task: Task
    
    @State private var isShowDetail = false
    var body: some View {
        
        Button {
            viewModel.registerObserveTaskInfo()
            isShowDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(task.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                   Image(systemName: task.category.icon)
                        .foregroundColor(task.category.color)
                    PriorityIndicator(priority: task.priority)
                }
                Text(task.title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(20)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .frame(width: 200, height: 120)
            .sheet(isPresented: $isShowDetail, content: {
                TaskDetailView(task: task)
                    .presentationDetents([.medium, .large])
            })
        }
        
    }
}
