//
//  TaskGroupView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskGroupView: View {
    @Binding var showAddTaskModal: Bool // Binding to control the modal

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Task Groups")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("4")
                    .foregroundColor(.purple)
                Spacer()
                Button(action: {
                    showAddTaskModal = true
                }) {
                    Image(systemName: "plus")
                }
            }
            VStack(spacing: 10) {
                NavigationLink {
                    TaskListView()
                } label: {
                    TaskGroupCard(title: "Office Project", tasks: 23, progress: 0.7, color: .pink)
                }
                TaskGroupCard(title: "Personal Project", tasks: 30, progress: 0.52, color: .purple)
                TaskGroupCard(title: "Daily Study", tasks: 30, progress: 0.87, color: .orange)
            }
        }
    }
}

struct TaskGroupCard: View {
    let title: String
    let tasks: Int
    let progress: Double
    let color: Color

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(.bold)
                Text("\(tasks) Tasks")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            CircleProgressView(progress: progress, color: color)
                .frame(minWidth: 50, idealWidth: 50, maxWidth: 150, minHeight: 50, idealHeight: 50, maxHeight: 150)
                .padding(.trailing, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
    }
}
