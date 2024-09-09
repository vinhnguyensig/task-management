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
                        NavigationLink {
                            TaskDetailView(task: task)
                        } label: {
                            TaskInProgress(
                                title: task.title,
                                project: task.category.rawValue,
                                color: task.category.color
                            )
                        }
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
    let title: String
    let project: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ProgressView(value: 0.1)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding(12)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(width: 180, height: 100)
    }
}
