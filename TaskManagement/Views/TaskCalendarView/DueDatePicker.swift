//
//  DueDatePicker.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import SwiftUI

struct DueDatePicker: View {
    @StateObject var viewModel: TaskCalendarViewModel
    @Binding var selectedDate: Date

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(dates(), id: \.self) { date in
                        CalendarDateView(date: date, isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate)) {
                            withAnimation(.spring()) {
                                selectedDate = date
                                scrollViewProxy.scrollTo(date, anchor: .center)
                            }
                        }
                        .id(date)
                    }
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                }
                .padding(.horizontal)
                .frame(height: 80)
                .onAppear {
                    scrollViewProxy.scrollTo(selectedDate, anchor: .center)
                }
            }
            .onChange(of: selectedDate) { newDate in
                withAnimation {
                    scrollViewProxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func dates() -> [Date] {
        let calendar = Calendar.current
        var dates = [Date]()
        
        // Show +/- 1 week from current date
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -2, to: today),
              let endDate = calendar.date(byAdding: .day, value: 90, to: today) else {
            return dates
        }

        var currentDate = startDate
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return dates
    }
}

// MARK: - CalendarDateView

struct CalendarDateView: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    private var dayOfWeek: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    private var dayOfMonth: String {
        date.formatted(.dateTime.day())
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayOfWeek)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .secondary)
            Text(dayOfMonth)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding(12)
        .frame(width: 60, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor : Color(.systemBackground))
        )
        .shadow(color: isSelected ? Color.accentColor.opacity(0.3) : .clear, radius: 4)
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : .isStaticText)
    }
}
