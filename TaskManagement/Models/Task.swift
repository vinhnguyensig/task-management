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
    var progress: Double
    var isCompleted: Bool
    var position: Int
    var attachments: [String]?
    let createdAt: Date

    // Custom initializer for default values
    init(id: String = UUID().uuidString,
         title: String,
         startDate: Date? = nil,
         dueDate: Date? = nil,
         estimateHour: Double? = nil,
         priority: TaskPriority? = nil,
         category: TaskCategory? = nil,
         brief: String? = nil,
         detail: String? = nil,
         assignees: [String]? = nil,
         progress: Double = 0,
         isCompleted: Bool = false,
         position: Int = 1,
         attachments: [String]? = nil,
         createdAt: Date = Date()) {
        
        self.id = id
        self.title = title
        self.startDate = startDate
        self.dueDate = dueDate
        self.estimateHour = estimateHour
        self.priority = priority
        self.category = category
        self.brief = brief
        self.detail = detail
        self.assignees = assignees
        self.progress = progress
        self.isCompleted = isCompleted
        self.position = position
        self.attachments = attachments
        self.createdAt = createdAt
    }
}
