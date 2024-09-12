//
//  TaskCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

//
//  TaskCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation
import SwiftUI

import SwiftUI

struct TaskCalendarView: View {
    @StateObject var viewModel = TaskCalendarViewModel()
    @State private var selectedDate: Date = Date()
    @State private var isExpanded: Bool = false
    @State private var pendingDate: Date?

    var body: some View {
        NavigationStack {
            VStack {
                // Calendar view at the top
                DueDateCalendarView(viewModel: viewModel, selectedDate: $selectedDate, isExpanded: $isExpanded)

                if !viewModel.taskGroups.isEmpty {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.taskGroups, id: \.key) { date, tasks in
                                    TaskSectionView(date: date, tasks: tasks, onToggleComplete: { task in
                                        // Handle toggle complete
                                    }, onTaskTapped: { task in
                                        // Handle task tapped
                                    })
                                    .id(date)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear
                                                .onChange(of: geo.frame(in: .global).minY) { yPos in
                                                    handleScrollPosition(yPos: yPos, date: date)
                                                }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                        .onChange(of: selectedDate) { newDate in
                            // Smoothly scroll to the selected date
                            withAnimation {
                                scrollProxy.scrollTo(newDate, anchor: .top)
                            }
                        }
                    }
                } else {
                    // Handle empty state
                   // EmptyStateView()
                }
            }
            .task {
                viewModel.loadTasks()
            }
            .navigationTitle("Task Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    // This function handles the scroll position and debounces the date update
    private func handleScrollPosition(yPos: CGFloat, date: Date) {
        let screenHeight = UIScreen.main.bounds.height

        // Update the date only when the section is near the center of the screen
        if yPos < screenHeight * 0.6 && yPos > 0 {
            pendingDate = date

            // Debounce the update to make it smoother
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if pendingDate == date {
                    withAnimation {
                        selectedDate = date
                    }
                }
            }
        }
    }
}

struct SectionHeaderView: View {
    let date: Date

    var body: some View {
        HStack(alignment: .bottom) {
            Text(Utils.formattedDate(date))
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.leading)
            Spacer()
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct TaskSectionView: View {
    let date: Date
    let tasks: [Task]
    let onToggleComplete: (Task) -> Void
    let onTaskTapped: (Task) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(date: date)

            ForEach(tasks) { task in
                TaskRowView(task: task, onToggleComplete: onToggleComplete, onTaskTapped: onTaskTapped)
                    .padding(.vertical, 4)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 16)
    }
}
