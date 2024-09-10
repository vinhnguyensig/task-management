//
//  CalanderDate.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import Foundation

struct CalendarDate: Identifiable {
    var id = UUID()
    var date: Date
    var isSelected: Bool = false
}
