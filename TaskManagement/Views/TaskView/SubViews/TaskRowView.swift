//
//  TaskRowView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import SwiftUI

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                if let dueDate = task.dueDate {
                    Text("Due: \(dueDate, formatter: taskDateFormatter)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if task.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            PriorityIndicator(priority: task.priority)
        }
        .padding()
    }
}

struct PriorityIndicator: View {
    let priority: TaskPriority
    
    var body: some View {
        Text(priority.rawValue.capitalized)
            .font(.caption)
            .padding(5)
            .background(priority.color)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}

private let taskDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()
