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
    @Persisted var priority: String?
    @Persisted var category: String?
    @Persisted var brief: String?
    @Persisted var detail: String?
    @Persisted var assignees: List<String> = List<String>()
    @Persisted var isCompleted: Bool = false
    @Persisted var postition: Int
    @Persisted var createdAt: Date = Date()

    // Convenience initializer for creating Task objects
    convenience init(title: String,
                     startDate: Date? = nil,
                     dueDate: Date? = nil,
                     estimateHour: Double? = nil,
                     priority: String? = nil,
                     category: String? = nil,
                     brief: String? = nil,
                     detail: String? = nil,
                     assignees: [String] = [],
                     isCompleted: Bool = false,
                     postition: Int = 1,
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
        self.isCompleted = isCompleted
        self.postition = postition
        self.createdAt = createdAt
    }
}

