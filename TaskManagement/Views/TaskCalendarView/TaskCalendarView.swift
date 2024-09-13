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
                calendarView
                taskListOrEmptyView
            }
            .task {
                viewModel.loadTasks()
            }
            .navigationTitle("Task Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }

    // Extracted calendar view for cleaner structure
    private var calendarView: some View {
        DueDateCalendarView(
            viewModel: viewModel,
            selectedDate: $selectedDate,
            isExpanded: $isExpanded
        )
    }

    // Conditional view for tasks or empty state
    private var taskListOrEmptyView: some View {
        Group {
            if !viewModel.taskGroups.isEmpty {
                TaskGroupListView
            } else {
                EmptyStateView()
            }
        }
    }

    // Task list with scroll view and lazy loading of sections
    private var TaskGroupListView: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.taskGroups, id: \.key) { date, tasks in
                        TaskSectionView(date: date, tasks: tasks, onToggleComplete: toggleTaskCompletion, onTaskTapped: taskTapped)
                            .id(date)
                            .background(geometryReaderForScrollPosition(date: date))
                    }
                }
                .padding(.horizontal, 8)
            }
            .onAppear {
                scrollToSelectedDate(selectedDate, using: scrollProxy)
            }
            .onChange(of: selectedDate) { newDate in
                if viewModel.isSelectedDate {
                    scrollToSelectedDate(newDate, using: scrollProxy)
                }
            }
        }
    }

    // GeometryReader for handling scroll position updates
    private func geometryReaderForScrollPosition(date: Date) -> some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .global).minY) { yPos in
                    handleScrollPosition(yPos: yPos, date: date)
                }
        }
    }

    // Scroll to the selected date
    private func scrollToSelectedDate(_ date: Date, using scrollProxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            scrollProxy.scrollTo(date, anchor: .top)
            viewModel.isSelectedDate = false
        }
    }

    // Handle scroll position updates for date changes
    private func handleScrollPosition(yPos: CGFloat, date: Date) {
        let screenHeight = UIScreen.main.bounds.height
        if yPos < screenHeight * 0.3 && yPos > 0 {
            pendingDate = date
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if pendingDate == date {
                    selectedDate = date
                }
            }
        }
    }
    
    // Helper for task toggle completion
    private func toggleTaskCompletion(_ task: Task) {
        // Handle task completion logic
    }

    // Helper for task tapped interaction
    private func taskTapped(_ task: Task) {
        // Handle task tapped logic
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

struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            Text("No tasks for the selected date")
                .foregroundColor(.gray)
                .font(.headline)
                .padding()
            Spacer()
        }
    }
}
