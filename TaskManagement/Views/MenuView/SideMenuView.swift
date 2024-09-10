//
//  SideMenuView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import SwiftUI

struct SideMenuView: View {
    var body: some View {
        VStack(alignment: .leading) {
            // Header Section
            HStack {
                Text("Task Management")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.top, 40)
            .padding(.horizontal, 20)

            Divider()
                .padding(.vertical, 10)

            // Menu Items
            List {
                menuItem(title: "All Tasks", systemImage: "list.bullet")
                menuItem(title: "Completed Tasks", systemImage: "checkmark.circle")
                menuItem(title: "Task Reminder", systemImage: "bell.badge.circle.fill")
                menuItem(title: "Priority", systemImage: "exclamationmark.circle")
                menuItem(title: "Categories", systemImage: "folder")
                menuItem(title: "Settings", systemImage: "gearshape")
            }
            .listStyle(PlainListStyle())
            .padding()
            
            Spacer()
        }
    }

    // Menu item helper to keep things DRY
    private func menuItem(title: String, systemImage: String) -> some View {
        NavigationLink(destination: EmptyView()) {
            Label(title, systemImage: systemImage)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
        }
    }
}

#Preview {
    SideMenuView()
}
