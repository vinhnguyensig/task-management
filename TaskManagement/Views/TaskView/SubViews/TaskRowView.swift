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
    let onToggleComplete: (Task) -> Void
    let onTaskTapped: (Task) -> Void
    @State private var isShowDetail = false
    @State private var isHighlighted = false
    
    var body: some View {
        HStack {
            // Checkmark Button to toggle task completion
            CheckmarkButton(isCompleted: task.isCompleted) {
                HapticManager.shared.triggerImpactFeedback(style: .medium)
                onToggleComplete(task)
            }

            // Task info and category icon
            TaskInfoView(task: task)
                .onTapGesture {
                    HapticManager.shared.triggerImpactFeedback(style: .medium)
                    highlightRow()
                    onTaskTapped(task)
                    isShowDetail = true
                }
                .sheet(isPresented: $isShowDetail, content: {
                    TaskDetailView(task: task)
                        .presentationDetents([.medium, .large])
                })
        }
        .padding()
        .background(isHighlighted ? Color.gray.opacity(0.2) : Color.clear)
        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
    
    private func highlightRow() {
        isHighlighted = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isHighlighted = false
        }
    }
}

// Refactored reusable checkmark button
struct CheckmarkButton: View {
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .secondary)
                .font(.system(size: 20))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Refactored reusable task info view
struct TaskInfoView: View {
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(task.title)
                    .font(.headline)
                    .foregroundColor(task.isCompleted ?.secondary : .primary)
                    .lineLimit(2)
                    .padding(4)
                    .strikethrough(task.isCompleted, color: .primary)
                
                if let dueDate = task.dueDate {
                    Text("Due date: \(Utils.taskDateFormatter(dueDate))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: task.category.icon)
                 .foregroundColor(task.category.color)
                .font(.system(size: 18))
                .padding(.trailing, 4)
            
            PriorityIndicator(priority: task.priority)
        }
    }
}

// View for showing priority indicator (unchanged)
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
