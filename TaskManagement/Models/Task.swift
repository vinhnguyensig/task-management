//
//  Task.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation

struct Task: Identifiable, Codable {
    let id: String
    var title: String
    var startDate: Date?
    var dueDate: Date?
    var estimateHour: Double?
    var priority: TaskPriority?
    var category: TaskCategory?
    var brief: String?
    var detail: String?
    var assignees: [String]?
    var isCompleted: Bool
    var postition: Int
    let createdAt: Date

    // Custom initializer for default values
    init(id: String = UUID().uuidString,
         title: String,
         startDate: Date? = nil,
         dueDate: Date? = nil,
         estimateHour: Double? = nil,
         priority: TaskPriority? = nil,
         category: TaskCategory? = nil,
         description: String? = nil,
         detail: String? = nil,
         assignees: [String]? = nil,
         isCompleted: Bool = false,
         postition: Int = 1,
         createdAt: Date = Date()) {
        
        self.id = id
        self.title = title
        self.startDate = startDate
        self.dueDate = dueDate
        self.estimateHour = estimateHour
        self.priority = priority
        self.category = category
        self.brief = description
        self.detail = detail
        self.assignees = assignees
        self.isCompleted = isCompleted
        self.postition = postition
        self.createdAt = createdAt
    }
}
