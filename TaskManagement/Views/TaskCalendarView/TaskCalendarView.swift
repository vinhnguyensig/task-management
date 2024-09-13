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

struct TaskCalendarView: View {
    @StateObject var viewModel = TaskCalendarViewModel()
    @State private var selectedDate: Date = Date()
    @State private var isExpanded: Bool = false
    @State private var pendingDate: Date?
    @State private var isFirstLoad = true
    
    var body: some View {
        NavigationStack {
            VStack {
                calendarView
                taskListOrEmptyView
            }
            .task {
                viewModel.loadTasks()
            }
            .navigationTitle("Due Dates")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemBackground))
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
                EmtyTaskDueDateView()
            }
        }
    }

    // Task list with scroll view and lazy loading of sections
    private var TaskGroupListView: some View {
        ScrollViewReader { scrollProxy in
            List {
                ForEach(viewModel.taskGroups, id: \.key) { date, tasks in
                    TaskDueDateSectionView(viewModel: viewModel, date: date, tasks: tasks, onToggleComplete: toggleTaskCompletion, onTaskTapped: taskTapped)
                        .id(date)
                        .background(
                            Group {
                                if isFirstLoad {
                                    Color.clear
                                } else {
                                    geometryReaderForScrollPosition(date: date)
                                }
                            }
                        )
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .listRowSpacing(8)
            .onChange(of: selectedDate) { newDate in
                if viewModel.isSelectedDate {
                    scrollToSelectedDate(newDate, using: scrollProxy)
                }
            }
            .onAppear {
                DispatchQueue.main.async {
                    isFirstLoad = false
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
    }
}
