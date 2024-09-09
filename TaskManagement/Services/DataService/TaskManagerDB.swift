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
    
    private func getRealm(completion: @escaping (Result<Realm, Error>) -> Void) {
        var config = Realm.Configuration()
        config.schemaVersion = 0
        do {
            let realm = try Realm(configuration: config)
            completion(.success(realm))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - CRUD Operations
    
    func createTask(task: Task, completion: @escaping (Error?) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let entity = self.taskEntity(from: task)
                do {
                    try realm.write {
                        realm.add(entity)
                    }
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func getAllTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let taskEntities = realm.objects(TaskEntity.self)
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func updateTask(task: Task, completion: @escaping (Error?) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let entity = self.taskEntity(from: task)
                do {
                    try realm.write {
                        realm.add(entity, update: .modified)
                    }
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func updateTaskPositions(_ tasks: [Task], completion: @escaping (Error?) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                do {
                    try realm.write {
                        for task in tasks {
                            guard let id = try? ObjectId(string: task.id),
                                  let entity = realm.object(ofType: TaskEntity.self, forPrimaryKey: id) else {
                                completion(NSError(domain: "RealmError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task not found"]))
                                return
                            }
                            
                            entity.position = task.position
                            
                        }
                    }
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func deleteTask(task: Task, completion: @escaping (Error?) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                guard let id = try? ObjectId(string: task.id),
                      let entityToDelete = realm.object(ofType: TaskEntity.self, forPrimaryKey: id) else {
                    completion(NSError(domain: "RealmError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task not found"]))
                    return
                }
                do {
                    try realm.write {
                        realm.delete(entityToDelete)
                    }
                    completion(nil)
                } catch {
                    completion(error)
                }
            case .failure(let error):
                completion(error)
            }
        }
    }
    
    func getTask(byID id: ObjectId, completion: @escaping (Result<Task?, Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let entity = realm.object(ofType: TaskEntity.self, forPrimaryKey: id)
                let task = entity != nil ? self.task(from: entity!) : nil
                completion(.success(task))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getCompletedTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let taskEntities = realm.objects(TaskEntity.self).filter("isCompleted == true")
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Helpers
    
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
        entity.position = task.position
        entity.attachments.append(objectsIn: task.attachments ?? [])
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
                    brief: entity.brief,
                    detail: entity.detail,
                    assignees: Array(entity.assignees),
                    isCompleted: entity.isCompleted,
                    position: entity.position,
                    createdAt: entity.createdAt)
    }
}
