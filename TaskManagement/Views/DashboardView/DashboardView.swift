//
//  DashboardView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct DashboardView: View {
    @State private var showAddTaskModal = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 5) {
                    TodayTaskProgressView()
                    InprogressSectionView()
                    TaskGroupView(showAddTaskModal: $showAddTaskModal)
                }
                .padding(.horizontal, 5)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Good Morning")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
