//
//  DashboardView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    
    @State private var showAddTaskModal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 5) {
                    TodayTaskProgressView(viewModel: viewModel)
                    TaskInProgressView(viewModel: viewModel)
                    TaskGroupView(viewModel: viewModel)
                }
                .padding(.horizontal, 5)
            }
            .navigationTitle("Task Management")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
