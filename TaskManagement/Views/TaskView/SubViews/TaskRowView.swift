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

            TaskInfoView(task: task)
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowDetail = true
                    HapticManager.shared.triggerImpactFeedback(style: .medium)
                    onTaskTapped(task)
                    highlightRow()
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

struct TaskRowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 4)
            .listRowInsets(EdgeInsets(top: 1, leading: 16, bottom: 1, trailing: 16))
            .background(Color(UIColor.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .listRowSeparator(.hidden)
    }
}
