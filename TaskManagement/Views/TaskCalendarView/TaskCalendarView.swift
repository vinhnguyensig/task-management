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
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.taskGroups, id: \.key) { date, tasks in
                                TaskSectionView(date: date, tasks: tasks, onToggleComplete: { task in
                                    // Handle toggle complete
                                }, onTaskTapped: { task in
                                    // Handle task tapped
                                })
                                .transition(.slide)
                            }
                        }
                        .padding(.horizontal, 8)
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
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

struct SectionHeaderView: View {
    let date: Date

    var body: some View {
        HStack(alignment: .bottom) {
            Text(Utils.formattedDate(date))
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.leading)
            Spacer()
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
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
                    .padding(.vertical, 4)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 16)
    }
}
