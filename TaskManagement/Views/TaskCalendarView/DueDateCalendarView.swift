//
//  DueDateCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import SwiftUI

struct DueDateCalendarView: View {
    @StateObject var viewModel: TaskCalendarViewModel
    @Binding var selectedDate: Date
    @Binding var isExpanded: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            // Month and expand/collapse button
            HStack {
                // Display the current month and year
                Text(Utils.monthYearFormatter(selectedDate))
                    .font(.title)
                    .padding(.leading, 16)

                // Add "Next Month" button here
                Button(action: {
                    if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
                        selectedDate = nextMonth
                        viewModel.selectedDate = nextMonth
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding(.leading, 10)

                Spacer()
                
                if !isSameDay(date1: selectedDate, date2: Date()) {
                    Button(action: {
                        selectedDate = Date()
                        viewModel.selectedDate = Date()
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("\(Calendar.current.component(.day, from: Date()))")
                                .bold()
                        }
                        .padding(8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                // Toggle button to expand/collapse the calendar
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .padding()
                }
            }
            
            // Calendar content
            if isExpanded {
                // Full Month View
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(daysOfTheMonth(), id: \.self) { day in
                        Button(action: {
                            selectedDate = day
                        }) {
                            Text("\(calendar.component(.day, from: day))")
                                .foregroundColor(isSameDay(date1: day, date2: selectedDate) ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background(isSameDay(date1: day, date2: selectedDate) ? Color.accentColor : Color.clear)
                                .clipShape(Circle())
                        }
                        .padding(4)
                    }
                }
            } else {
                DueDatePicker(viewModel: viewModel, selectedDate: $selectedDate)
            }
        }
    }
    
    private func tasksForDate(_ date: Date) -> [Task] {
        viewModel.tasks.filter { task in
            let taskDate = task.dueDate ?? Date()
            return calendar.isDate(taskDate, inSameDayAs: date)
        }
    }
    
    // Generates days for the current month
    func daysOfTheMonth() -> [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedDate) else { return [] }
        let days = range.compactMap { day -> Date? in
            calendar.date(bySetting: .day, value: day, of: selectedDate)
        }
        return days
    }
    
    // Generates days for the current week
    func daysOfTheWeek() -> [Date] {
        guard let weekRange = calendar.range(of: .day, in: .weekOfMonth, for: selectedDate) else { return [] }
        let days = weekRange.compactMap { day -> Date? in
            calendar.date(bySetting: .day, value: day, of: selectedDate)
        }
        return days
    }
    
    // Helper to check if two dates are the same day
    func isSameDay(date1: Date, date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // Format date for tasks
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }
}
