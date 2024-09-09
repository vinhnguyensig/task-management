//
//  InprogressSectionView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct InprogressSectionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Section Title
            HStack {
                Text("In Progress")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("6")
                    .font(.callout)
                    .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 16)
            
            // Horizontal Scroll View for tasks
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // Task Navigation Link Example
                    NavigationLink {
                        let task = Task(title: "Hello world!")
                        TaskDetailView(task: task)
                    } label: {
                        TaskInProgress(title: "Grocery shopping", project: "Office Project", color: .blue)
                    }

                    // Static Task Cards
                    TaskInProgress(title: "Uber Eats redesign", project: "Personal Project", color: .orange)
                    TaskInProgress(title: "Pet Project", project: "Personal Project", color: .orange)
                }
                .padding(.leading, 16)
                .padding(.vertical, 5)
            }
        }
        .padding(.vertical)
    }
}

struct TaskInProgress: View {
    let title: String
    let project: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Project Name (Caption)
            Text(project)
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Task Title
            Text(title)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // Progress View
            ProgressView(value: 0.7)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding(12)
        .background(Color(UIColor.systemBackground)) // White in light mode, adjusts for dark mode
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2) // Softer shadow
        .frame(width: 180, height: 100)
    }
}
