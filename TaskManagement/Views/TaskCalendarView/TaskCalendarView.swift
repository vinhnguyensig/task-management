//
//  TaskCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

//
//  TaskCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation
import SwiftUI

struct TaskCalendarView: View {
    @StateObject var viewModel = TaskCalendarViewModel()
    @State private var selectedDate: Date = Date()
    @State private var isExpanded: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                DueDateCalendarView(viewModel: viewModel, selectedDate: $selectedDate, isExpanded: $isExpanded)

                if !viewModel.taskGroups.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 16) {  // Increased spacing for visual clarity
                            ForEach(viewModel.taskGroups, id: \.key) { date, tasks in
                                TaskSectionView(date: date, tasks: tasks, onToggleComplete: { task in
                                    // Handle toggle complete
                                }, onTaskTapped: { task in
                                    // Handle task tapped
                                })
                                .transition(.slide)  // Smooth transition when sections appear
                            }
                        }
                        .padding(.horizontal, 16) // Consistent horizontal padding
                    }
                } else {
                    //EmptyStateView()
                }
            }
            .task {
                viewModel.loadTasks()
            }
            .navigationTitle("Task Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground)) // Adapt background color
        }
    }
}

struct SectionHeaderView: View {
    let date: Date

    var body: some View {
        HStack(alignment: .bottom) {
            Text(Utils.formattedDate(date))
                .font(.headline)
                .foregroundColor(.primary)  // Ensure the text adapts to light/dark mode
                .padding(.vertical, 8)
                .padding(.leading)
            Spacer()  // Ensure the text doesn't feel cramped
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))  // Improved contrast for header
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct TaskSectionView: View {
    let date: Date
    let tasks: [Task]
    let onToggleComplete: (Task) -> Void
    let onTaskTapped: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(date: date)

            ForEach(tasks) { task in
                TaskRowView(task: task, onToggleComplete: onToggleComplete, onTaskTapped: onTaskTapped)
                    .padding(.vertical, 4)  // Added padding for each row
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                    .contentShape(Rectangle()) // Ensures the entire row is tappable
            }
        }
        .padding(.horizontal, 16) // Consistent padding for section
        .padding(.bottom, 16) // Additional bottom padding for spacing between sections
    }
}
