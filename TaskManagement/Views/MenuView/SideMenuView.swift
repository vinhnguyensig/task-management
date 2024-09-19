//
//  SideMenuView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import SwiftUI

struct SideMenuView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                List {
                    Section {
                        SideMenuHeaderView()
                    }
                    .listRowSeparator(.hidden)
                    
                    taskListItem(title: "All Tasks", systemImage: "list.bullet", color: .blue)
                    taskListItem(title: "Completed Tasks", systemImage: "checkmark.circle", color: .green, status: TaskStatus.completed.rawValue)
                    taskListItem(title: "Backlog", systemImage: "tray.full.fill", color: .gray,  status: TaskStatus.backlog.rawValue)
                    generateTasks(title: "Tasks Generator", systemImage: "sparkles", color: .purple)
                    menuItem(title: "Task Reminder", systemImage: "bell.badge.circle.fill", color: .orange)
                    menuItem(title: "Priority", systemImage: "flag.fill", color: .red)
                    menuItem(title: "Categories", systemImage: "folder", color: .purple)
                    menuItem(title: "Feedback", systemImage: "ellipsis.message", color: .pink)
                    menuItem(title: "Settings", systemImage: "gearshape", color: .gray)
                }
                .listStyle(PlainListStyle())
                .padding()
                
                Spacer()
            }
            .navigationTitle("More")
        }
    }

    private func menuItem(title: String, systemImage: String, color: Color) -> some View {
        NavigationLink(destination: ComingSoonView()) {
            Label(title, systemImage: systemImage)
                .font(.body)
                .foregroundColor(color)
                .padding(.vertical, 8)
        }
    }
    
    private func taskListItem(title: String, systemImage: String, color: Color, status: String? = nil, category: String? = nil) -> some View {
        NavigationLink(destination: TaskListView(status: status, customTitle: title, isAll: true)) {
            Label(title, systemImage: systemImage)
                .font(.body)
                .foregroundColor(color)
                .padding(.vertical, 8)
        }
    }
    
    private func generateTasks(title: String, systemImage: String, color: Color) -> some View {
        NavigationLink(destination: GenerateTaskView()) {
            Label(title, systemImage: systemImage)
                .font(.body)
                .foregroundColor(color)
                .padding(.vertical, 8)
        }
    }
}
