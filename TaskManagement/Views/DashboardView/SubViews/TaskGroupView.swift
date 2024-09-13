//
//  TaskGroupView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskGroupView: View {
    
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Section
            HStack {
                Text("Task Groups")
                    .font(.title3)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                ForEach(viewModel.tasksByCategory, id: \.category) { taskGroup in
                    NavigationLink {
                        TaskListView(category: taskGroup.category?.rawValue)
                    } label: {
                        let categoryTitle = taskGroup.category?.rawValue ?? "Others"
                        let totalTasks = taskGroup.tasks.count
                        let completedTasks = taskGroup.tasks.filter {
                            $0.isCompleted == true
                        }
                        let totalProgress = Double(completedTasks.count) / Double(totalTasks)
                        let categoryColor = taskGroup.category?.color ?? .gray
                        let categoryIcon = taskGroup.category?.icon ?? "questionmark.circle"
                        
                        TaskGroupCard(
                            title: categoryTitle,
                            tasks: totalTasks,
                            progress: totalProgress,
                            color: categoryColor,
                            icon: categoryIcon
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
        .padding(.bottom, 50)
        .onAppear {
            viewModel.loadGroupTasks()
        }
    }
}

struct TaskGroupCard: View {
    let title: String
    let tasks: Int
    let progress: Double
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .padding(.trailing, 8)

            // Task Details
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text("\(tasks) Tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()

            CircleProgressView(progress: progress, color: TaskProgress.getProgressColor(progress: progress))
                .frame(width: 50, height: 50)
                .padding(.trailing, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
