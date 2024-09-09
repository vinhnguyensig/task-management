//
//  TaskDetailView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    
    var body: some View {
        Text(task.title)
            .navigationBarTitle("Task Detail", displayMode: .inline)
    }
}

