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
            .navigationTitle("More")
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
