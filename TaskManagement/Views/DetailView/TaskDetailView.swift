//
//  TaskDetailView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskDetailView: View {
    @State var task: Task
    
    @StateObject var viewModel = TaskDetailsViewModel()
    @StateObject var reminderViewModel = TaskReminderViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @State private var brief: String = ""
    @State private var detail: String = ""
    @State private var isAddReminder = false
    @State private var isNavigateEdit = false
  
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Task Title
                    Text(task.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                        .accessibilityAddTraits(.isHeader)
                    
                    // Task Details (Priority, Category, Status)
                    HStack(alignment: .center, spacing: 8) {
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
                            .padding(.leading, 2)
                        
                        Spacer()
                        
                        // Status
                        task.status.icon
                            .foregroundColor(task.status.color)
                        Text(task.status.rawValue.capitalized)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 8)
                    
                    Divider()
                    
                    // Start Date and Due Date
                    if let dueDate = task.dueDate {
                        VStack(alignment: .leading, spacing: 4) {
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
                        
                        HStack{
                            Text("Reminder")
                                .foregroundColor(.secondary)
                            Spacer()
                            Button {
                                if isAddReminder {
                                    reminderViewModel.removeReminder(id: task.id)
                                    isAddReminder = false
                                } else {
                                    reminderViewModel.setReminder(task: task)
                                }
                            } label: {
                                Image(systemName: "bell.badge.circle.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(isAddReminder ? .blue : .gray)
                            }
                            .onReceive(reminderViewModel.$notificationAuthorized, perform: { status in
                                if status {
                                    isAddReminder = status
                                }
                            })
                        }
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
                isAddReminder = reminderViewModel.isSetReminder(id: task.id)
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "arrowshape.down.circle")
                            .foregroundColor(.gray)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        viewModel.registerObserveTaskInfo()
                        isNavigateEdit = true
                    }
                }
            }
            .navigationDestination(isPresented: $isNavigateEdit) {
                AddTaskView(task: task)
            }
            .onReceive(viewModel.$task, perform: { info in
                if let nTask = info {
                    task = nTask
                }
            })
        }
    }
}
