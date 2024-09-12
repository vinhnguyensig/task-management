//
//  Calendar+Extension.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 12/9/24.
//

import Foundation

extension Calendar {
    func generateDates(for component: Calendar.Component, with referenceDate: Date) -> [Date] {
        guard let range = self.range(of: .day, in: component, for: referenceDate) else { return [] }
        return range.compactMap { day in
            self.date(bySetting: .day, value: day, of: referenceDate)
        }
    }

    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        self.isDate(date1, inSameDayAs: date2)
    }
}
