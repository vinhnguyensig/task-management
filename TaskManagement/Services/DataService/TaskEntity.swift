//
//  TaskEntity.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import RealmSwift

class TaskEntity: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
    @Persisted var title: String = ""
    @Persisted var startDate: Date?
    @Persisted var dueDate: Date?
    @Persisted var estimateHour: Double?
    @Persisted var priority: String
    @Persisted var category: String
    @Persisted var brief: String?
    @Persisted var detail: String?
    @Persisted var assignees: List<String> = List<String>()
    @Persisted var progress: Double = 0
    @Persisted var isCompleted: Bool = false
    @Persisted var position: Int
    @Persisted var attachments: List<String> = List<String>()
    @Persisted var createdAt: Date = Date()

    // Convenience initializer for creating Task objects
    convenience init(title: String,
                     startDate: Date? = nil,
                     dueDate: Date? = nil,
                     estimateHour: Double? = nil,
                     priority: String,
                     category: String,
                     brief: String? = nil,
                     detail: String? = nil,
                     assignees: [String] = [],
                     progress: Double = 0,
                     isCompleted: Bool = false,
                     position: Int = 1,
                     attachments: [String] = [],
                     createdAt: Date = Date()) {
        
        self.init()
        self.title = title
        self.startDate = startDate
        self.dueDate = dueDate
        self.estimateHour = estimateHour
        self.priority = priority
        self.category = category
        self.brief = brief
        self.detail = detail
        self.assignees.append(objectsIn: assignees)
        self.progress = progress
        self.isCompleted = isCompleted
        self.position = position
        self.attachments.append(objectsIn: attachments)
        self.createdAt = createdAt
    }
}

