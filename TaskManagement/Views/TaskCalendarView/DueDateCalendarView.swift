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
            CalendarHeaderView(selectedDate: $selectedDate, isExpanded: $isExpanded, viewModel: viewModel)

            if isExpanded {
                FullMonthView(selectedDate: $selectedDate, daysOfTheMonth: daysOfTheMonth())
            } else {
                DueDatePicker(viewModel: viewModel, selectedDate: $selectedDate)
            }
        }
    }
    
    private func daysOfTheMonth() -> [Date] {
        calendar.generateDates(for: .month, with: selectedDate)
    }
}

// MARK: - Calendar Header View
struct CalendarHeaderView: View {
    @Binding var selectedDate: Date
    @Binding var isExpanded: Bool
    var viewModel: TaskCalendarViewModel
    private let calendar = Calendar.current
    
    var body: some View {
        HStack {
            Text(Utils.monthYearFormatter(selectedDate))
                .font(.title2)
                .padding(.leading, 16)

            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .padding(.leading, 10)
            }

            Spacer()

            if !calendar.isSameDay(selectedDate, Date()) {
                Button(action: resetToToday) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("\(calendar.component(.day, from: Date()))")
                            .bold()
                    }
                    .padding(8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                }
            }

            Button(action: toggleExpand) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .padding()
            }
        }
    }

    private func nextMonth() {
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = nextMonth
        }
    }

    private func resetToToday() {
        selectedDate = Date()
    }

    private func toggleExpand() {
        withAnimation {
            isExpanded.toggle()
        }
    }
}

// MARK: - Full Month View
struct FullMonthView: View {
    @Binding var selectedDate: Date
    var daysOfTheMonth: [Date]
    private let calendar = Calendar.current
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
            ForEach(daysOfTheMonth, id: \.self) { day in
                Button(action: { selectedDate = day }) {
                    Text("\(calendar.component(.day, from: day))")
                        .foregroundColor(isSameDay(day, selectedDate) ? .white : .primary)
                        .frame(width: 40, height: 40)
                        .background(isSameDay(day, selectedDate) ? Color.accentColor : Color.clear)
                        .clipShape(Circle())
                }
                .padding(4)
            }
        }
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
}

