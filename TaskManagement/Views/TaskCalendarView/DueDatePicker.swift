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
                            ShareService.shared.currentSelectedDate = date
                            withAnimation(.spring()) {
                                viewModel.isSelectedDate = true
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
                .frame(height: 70)
            }
            .onChange(of: selectedDate) { newDate in
                if viewModel.isSelectedToday || !viewModel.isSelectedDate {
                    scrollViewProxy.scrollTo(newDate, anchor: .center)
                }

                if viewModel.isSelectedToday {
                    viewModel.isSelectedToday = false
                }

                if !viewModel.isSelectedDate {
                    ShareService.shared.currentSelectedDate = newDate
                }
            }
            .onAppear {
                if let date = ShareService.shared.currentSelectedDate {
                    scrollViewProxy.scrollTo(date, anchor: .center)
                }
            }
        }
    }
    
    // MARK: - Private Methods

    private func dates() -> [Date] {
        return viewModel.datesOfYear()
    }
}
