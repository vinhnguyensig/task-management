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
                    Text("Due: \(dueDate, formatter: Utils.taskDateFormatter)")
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
        ZStack {
            Circle()
                .fill(priority.color)
                .frame(width: 20, height: 20)
            
            Text(priority.rawValue.prefix(1).uppercased())
                .font(.caption.bold())
                .foregroundColor(.white)
        }
    }
}

