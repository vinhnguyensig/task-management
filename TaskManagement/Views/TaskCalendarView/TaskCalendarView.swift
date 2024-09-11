//
//  TaskCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation
import SwiftUI

struct TaskCalendarView: View {
    @StateObject var viewModel = TaskListViewModel()
    
    @State private var selectedDate: Date = Date()

    var body: some View {
        VStack {
            DueDateCalendarView(viewModel: viewModel, selectedDate: $selectedDate)
        }
        .task {
            viewModel.loadTasks()
        }
    }
}
