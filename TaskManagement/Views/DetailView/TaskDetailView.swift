//
//  TaskDetailView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskDetailView: View {
    var task: Task
    
    @State private var brief: String = ""
    @State private var detail: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Task Title
                Text(task.title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
                    .accessibilityAddTraits(.isHeader)
                
                // Task Details (Priority, Category, Status)
                HStack(alignment: .center, spacing: 16) {
                    // Priority
                    Label(task.priority.rawValue.capitalized, systemImage: "flag.fill")
                        .padding(4)
                        .background(task.priority.color)
                        .cornerRadius(6)
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .accessibilityLabel("Priority: \(task.priority.rawValue)")
                    
                    Spacer()
                    
                    // Category
                    task.category.icon
                        .foregroundColor(task.category.color)
                    Text(task.category.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Status
                    task.status.icon
                        .foregroundColor(task.status.color)
                    Text(task.status.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 8)
                
                // Start Date and Due Date
                if let startDate = task.startDate, let dueDate = task.dueDate {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Label("Start Date", systemImage: "calendar")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(Utils.formattedDate(startDate))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        HStack {
                            Label("Due Date", systemImage: "calendar.badge.exclamationmark")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(Utils.formattedDate(dueDate))
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.vertical, 8)
                    .accessibilityElement(children: .combine)
                }
                
                Divider()
                
                // Brief Description
                VStack(alignment: .leading, spacing: 8) {
                    Label("Brief Description", systemImage: "text.book.closed")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $brief)
                        .frame(minHeight: 60, maxHeight: 100)
                        .padding(1)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.vertical, 8)
                
                // Detailed Description
                VStack(alignment: .leading, spacing: 8) {
                    Label("Task Detail", systemImage: "doc.text")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $detail)
                        .frame(minHeight: 100, maxHeight: 160)
                        .padding(1)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    Button(action: {
                        // Action to generate detailed description
                    }) {
                        Label("Generate task detail with AI", systemImage: "wand.and.stars")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .onAppear {
            if let des = task.brief {
                brief = des
            }
            if let cont = task.detail {
                detail = cont
            }
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
