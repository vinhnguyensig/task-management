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
                    menuItem(title: "All Tasks", systemImage: "list.bullet", color: .blue)
                    menuItem(title: "Completed Tasks", systemImage: "checkmark.circle", color: .green)
                    menuItem(title: "Backlog", systemImage: "tray.full.fill", color: .gray)
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

    // Menu item helper to keep things DRY
    private func menuItem(title: String, systemImage: String, color: Color) -> some View {
        NavigationLink(destination: EmptyView()) {
            Label(title, systemImage: systemImage)
                .font(.body)
                .foregroundColor(color)  // Set the color here
                .padding(.vertical, 8)
        }
    }
}
