//
//  TaskGroupView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskGroupView: View {
    @Binding var showAddTaskModal: Bool

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
            
            // Task Group Cards
            VStack(spacing: 12) {
                NavigationLink {
                    TaskListView()
                } label: {
                    TaskGroupCard(title: "Office Project", tasks: 23, progress: 0.7, color: .pink)
                }
                
                TaskGroupCard(title: "Personal Project", tasks: 30, progress: 0.52, color: .purple)
                TaskGroupCard(title: "Daily Study", tasks: 30, progress: 0.87, color: .orange)
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 16)
    }
}

struct TaskGroupCard: View {
    let title: String
    let tasks: Int
    let progress: Double
    let color: Color

    var body: some View {
        HStack {
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
