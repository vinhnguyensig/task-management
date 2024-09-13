//
//  TaskDueDateSectionView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import SwiftUI

struct TaskDueDateSectionView: View {
    @ObservedObject var viewModel: TaskCalendarViewModel
    let date: Date
    let tasks: [TaskModel]
    let onToggleComplete: (TaskModel) -> Void
    let onTaskTapped: (TaskModel) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            DateSectionHeaderView(date: date)
            ForEach(tasks) { task in
                TaskRowView(task: task, onToggleComplete: onToggleComplete, onTaskTapped: onTaskTapped)
                    .applyTaskRowStyle()
            }
            .onDelete(perform: viewModel.deleteTask)
        }
    }
}

struct DateSectionHeaderView: View {
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
        .background(Color(UIColor.systemBackground))
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}
