//
//  TaskManagerDB.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import RealmSwift

class TaskManagerDB {
    static let shared = TaskManagerDB()

    private init() {}
    
    private func getRealm() async throws -> Realm {
        var config = Realm.Configuration()
        config.schemaVersion = 0
        return try await Realm(configuration: config)
    }
    
    // MARK: - CRUD Operations
    
    func createTask(task: Task) async throws {
        let realm = try await getRealm()
        let entity = taskEntity(from: task)
        
        try realm.write {
            realm.add(entity)
        }
    }
    
    func getAllTasks() async throws -> [Task] {
        let realm = try await getRealm()
        let taskEntities = realm.objects(TaskEntity.self)
        return taskEntities.map { task(from: $0) }
    }
    
    func updateTask(task: Task) async throws {
        let realm = try await getRealm()
        let entity = taskEntity(from: task)
        
        try realm.write {
            realm.add(entity, update: .modified)
        }
    }
    
    func deleteTask(task: Task) async throws {
        let realm = try await getRealm()
        
        guard let id = try? ObjectId(string: task.id),
              let entityToDelete = realm.object(ofType: TaskEntity.self, forPrimaryKey: id) else {
            throw NSError(domain: "RealmError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task not found"])
        }
        
        try realm.write {
            realm.delete(entityToDelete)
        }
    }
    
    func getTask(byID id: ObjectId) async throws -> Task? {
        let realm = try await getRealm()
        guard let entity = realm.object(ofType: TaskEntity.self, forPrimaryKey: id) else {
            return nil
        }
        return task(from: entity)
    }
    
    func getCompletedTasks() async throws -> [Task] {
        let realm = try await getRealm()
        let taskEntities = realm.objects(TaskEntity.self).filter("isCompleted == true")
        return taskEntities.map { task(from: $0) }
    }
    
    // MARK: - Private Helpers (for Realm conversion)
    
    private func taskEntity(from task: Task) -> TaskEntity {
        let entity = TaskEntity()
        entity.id = task.id.isEmpty ? ObjectId.generate() : (try? ObjectId(string: task.id)) ?? ObjectId.generate()
        entity.title = task.title
        entity.startDate = task.startDate
        entity.dueDate = task.dueDate
        entity.estimateHour = task.estimateHour
        entity.priority = task.priority?.rawValue
        entity.category = task.category?.rawValue
        entity.brief = task.brief
        entity.detail = task.detail
        entity.assignees.append(objectsIn: task.assignees ?? [])
        entity.isCompleted = task.isCompleted
        entity.createdAt = task.createdAt
        entity.postition = task.postition
        return entity
    }
    
    private func task(from entity: TaskEntity) -> Task {
        return Task(id: entity.id.stringValue,
                    title: entity.title,
                    startDate: entity.startDate,
                    dueDate: entity.dueDate,
                    estimateHour: entity.estimateHour,
                    priority: entity.priority != nil ? TaskPriority(rawValue: entity.priority!) : nil,
                    category: entity.category != nil ? TaskCategory(rawValue: entity.category!) : nil,
                    description: entity.brief,
                    detail: entity.detail,
                    assignees: Array(entity.assignees),
                    isCompleted: entity.isCompleted,
                    postition: entity.postition,
                    createdAt: entity.createdAt)
    }
}
