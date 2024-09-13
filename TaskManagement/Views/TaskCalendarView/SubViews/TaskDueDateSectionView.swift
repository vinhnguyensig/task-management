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
    let tasks: [Task]
    let onToggleComplete: (Task) -> Void
    let onTaskTapped: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            DateSectionHeaderView(date: date)
            ForEach(tasks) { task in
                TaskRowView(task: task, onToggleComplete: onToggleComplete, onTaskTapped: onTaskTapped)
                    .applyTaskRowStyle()
            }
            .onDelete(perform: viewModel.deleteTask)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
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

struct TaskRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 1)
            .listRowInsets(EdgeInsets(top: 1, leading: 16, bottom: 1, trailing: 16))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .listRowSeparator(.hidden)
    }
}
