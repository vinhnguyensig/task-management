//
//  TaskCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation
import SwiftUI

struct TaskCalendarView: View {
    @StateObject var viewModel = TaskCalendarViewModel()
    
    @State private var selectedDate: Date = Date()
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack {
            DueDateCalendarView(viewModel: viewModel, selectedDate: $selectedDate, isExpanded: $isExpanded)
            Spacer()
            Text("Comming Soon...")
                .foregroundColor(.primary)
            Spacer()
        }
        .task {
            viewModel.loadTasks()
        }
    }
}
