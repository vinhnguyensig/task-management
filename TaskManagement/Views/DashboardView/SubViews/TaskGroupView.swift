//
//  TaskGroupView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskGroupView: View {
    
    @StateObject var viewModel: DashboardViewModel

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
            
            // Task Group Cards (Display the task groups dynamically)
            VStack(spacing: 12) {
                ForEach(viewModel.tasksByCategory, id: \.category) { taskGroup in
                    // Extract category title or use "Uncategorized" if nil
                    let categoryTitle = taskGroup.category?.rawValue ?? "Others"
                    
                    // Calculate the overall progress (sum of task progress / total tasks)
                    let totalTasks = taskGroup.tasks.count
                    let totalProgress = taskGroup.tasks.reduce(0) { $0 + $1.progress } / Double(totalTasks)
                    
                    // Extract color and icon from TaskCategory or use default values for uncategorized tasks
                    let categoryColor = taskGroup.category?.color ?? .gray
                    let categoryIcon = taskGroup.category?.icon ?? Image(systemName: "questionmark.circle")
                    
                    // Display a TaskGroupCard for each group
                    TaskGroupCard(
                        title: categoryTitle,
                        tasks: totalTasks,
                        progress: totalProgress,
                        color: categoryColor,
                        icon: categoryIcon
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
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
    let icon: Image

    var body: some View {
        HStack {
            // Task Category Icon
            icon
                .font(.largeTitle)
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
            
            // Progress Circle
            CircleProgressView(progress: progress, color: color)
                .frame(width: 50, height: 50)
                .padding(.trailing, 8)
        }
        .padding()
        .background(Color(UIColor.systemBackground)) // Adapts to light/dark mode
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Softer shadow
    }
}
