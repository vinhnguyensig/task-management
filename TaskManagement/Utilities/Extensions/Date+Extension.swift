//
//  Date+Extension.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation

extension Date {
    func formatted(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func dayOfWeek() -> String {
        return formatted("E") // "Sun", "Mon", etc.
    }
    
    func dayOfMonth() -> String {
        return formatted("d")  // "23", "24", etc.
    }
    
    func monthName() -> String {
        return formatted("MMM")  // "May"
    }
}
