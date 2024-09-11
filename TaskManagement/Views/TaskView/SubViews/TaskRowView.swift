//
//  TaskRowView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import SwiftUI

struct TaskRowView: View {
    @ObservedObject var viewModel: TaskListViewModel
    
    let task: Task
    @State private var isShowDetail = false
    
    var body: some View {
        
        Button(action: {
            viewModel.registerObserveTaskInfo()
            isShowDetail = true
        }, label: {
            HStack {
                VStack(alignment: .leading) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    if let dueDate = task.dueDate {
                        Text("Due date: \(Utils.taskDateFormatter(dueDate))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if task.status == .done {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                
                PriorityIndicator(priority: task.priority)
            }
            .padding()
            .sheet(isPresented: $isShowDetail, content: {
                TaskDetailView(task: task)
            })
        })
        
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

