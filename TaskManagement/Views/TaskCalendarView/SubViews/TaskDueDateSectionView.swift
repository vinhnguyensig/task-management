//
//  TaskDueDateSectionView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import SwiftUI

struct TaskDueDateSectionView: View {
    let date: Date
    let tasks: [Task]
    let onToggleComplete: (Task) -> Void
    let onTaskTapped: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DateSectionHeaderView(date: date)
            ForEach(tasks) { task in
                TaskRowView(task: task, onToggleComplete: onToggleComplete, onTaskTapped: onTaskTapped)
                    .applyTaskRowStyle()
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
    }
}

struct TaskRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}
