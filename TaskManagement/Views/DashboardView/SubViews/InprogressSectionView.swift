//
//  InprogressSectionView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct InprogressSectionView: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("In Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("6")
                    .foregroundColor(.purple)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    NavigationLink {
                        let task = Task(title: "Hello world!")
                        TaskDetailView(task: task)
                    } label: {
                        TaskInProgress(title: "Grocery shopping", project: "Office Project", color: .blue)
                    }
                    TaskInProgress(title: "Uber Eats redesign", project: "Personal Project", color: .orange)
                    TaskInProgress(title: "Pet Project", project: "Personal Project", color: .orange)
                }
                .padding(.vertical, 5)
            }
        }
        .padding(.vertical)
    }
}

struct TaskInProgress: View {
    let title: String
    let project: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text(project)
                .font(.caption)
                .foregroundColor(.gray)
            Text(title)
                .fontWeight(.bold)
            ProgressView(value: 0.7)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 2)
        .frame(width: 200, height: 100)
    }
}
