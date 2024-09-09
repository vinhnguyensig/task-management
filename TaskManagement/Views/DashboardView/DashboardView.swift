//
//  DashboardView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//


import SwiftUI

// MARK: - DashboardView

struct DashboardView: View {
    @State private var showAddTaskModal = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                ScrollView {
                    VStack {
                        TodayTaskProgressView()
                        InprogressSectionView()
                        TaskGroupView(showAddTaskModal: $showAddTaskModal)
                    }
                    .padding(.horizontal)
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.98, green: 0.98, blue: 1), .white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationTitle("Good Morning")
            .navigationBarHidden(false)
        }
    }
}
