//
//  TodayTaskProgressView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TodayTaskProgressView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    @State private var navigateToTaskList: Bool = false
    
    var body: some View {
        ZStack {
            // Background Shape
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.systemBackground))
                .frame(height: 150)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3)

            HStack(alignment: .center, spacing: 8) {
                // Text Content
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today's Task")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(viewModel.tasksTodayStatus)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        navigateToTaskList = true
                    }) {
                        Text("View Task")
                            .font(.callout)
                            .fontWeight(.medium)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.leading, 16)

                Spacer()
                
                // Progress Circle
                CircleProgressView(progress: viewModel.tasksTodayProgress, color: TaskProgress.getProgressColor(progress: viewModel.tasksTodayProgress))
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 16)
            }
        }
        .padding(.horizontal, 16)
        .navigationDestination(isPresented: $navigateToTaskList) {
            TaskListView()
        }
        .onAppear {
            viewModel.loadTodayProgress()
        }
    }
}
