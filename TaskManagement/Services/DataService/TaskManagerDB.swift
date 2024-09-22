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
        config.schemaVersion = 1
        do {
            let realm = try Realm(configuration: config)
            completion(.success(realm))
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - CRUD Operations
    
    func createTask(task: TaskModel, completion: @escaping (Error?) -> Void) {
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
    
    func getAllTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let predicate = NSPredicate(format: "parentId == nil")
                let taskEntities = realm.objects(TaskEntity.self).filter(predicate)
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTasks(by category: String, completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let predicate = NSPredicate(format: "category == %@ AND parentId == nil", category)
                let taskEntities = realm.objects(TaskEntity.self).filter(predicate)
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTasks(status: String, isToday: Bool, category: String?, completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                var predicate = NSPredicate(format: "status == %@ AND parentId == nil", status)
                if let category = category {
                    predicate = NSPredicate(format: "status == %@ AND category == %@ AND parentId == nil", status, category)
                } else if isToday {
                    let calendar = Calendar.current
                    let startOfDay = calendar.startOfDay(for: Date())
                    if let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) {
                        predicate = NSPredicate(format: "dueDate >= %@ AND dueDate < %@ AND status == %@ AND parentId == nil", startOfDay as NSDate, endOfDay as NSDate, status)
                    }
                }
                let taskEntities = realm.objects(TaskEntity.self).filter(predicate)
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchTodayTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: Date())
                if let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) {
                    let predicate = NSPredicate(format: "dueDate >= %@ AND dueDate < %@ AND parentId == nil", startOfDay as NSDate, endOfDay as NSDate)
                    let taskEntities = realm.objects(TaskEntity.self).filter(predicate)
                    let tasks = Array(taskEntities.map { self.task(from: $0) })
                    completion(.success(tasks))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSubtasks(parentId: String, completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let predicate = NSPredicate(format: "parentId == %@", parentId)
                let taskEntities = realm.objects(TaskEntity.self).filter(predicate)
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    func updateTask(task: TaskModel, completion: @escaping (Error?) -> Void) {
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
    
    func updateTaskPositions(_ tasks: [TaskModel], completion: @escaping (Error?) -> Void) {
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
    
    func deleteTask(task: TaskModel, completion: @escaping (Error?) -> Void) {
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
    
    func getTask(byID id: ObjectId, completion: @escaping (Result<TaskModel?, Error>) -> Void) {
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
    
    func getInProgressTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let predicate = NSPredicate(format: "isCompleted == false AND status != %@ AND parentId == nil", TaskStatus.backlog.rawValue)
                let taskEntities = realm.objects(TaskEntity.self).filter(predicate)
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    func getCompletedTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        getRealm { result in
            switch result {
            case .success(let realm):
                let taskEntities = realm.objects(TaskEntity.self).filter("isCompleted == true AND parentId == nil")
                let tasks = Array(taskEntities.map { self.task(from: $0) })
                completion(.success(tasks))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func taskEntity(from task: TaskModel) -> TaskEntity {
        let entity = TaskEntity()
        entity.id = task.id.isEmpty ? ObjectId.generate() : (try? ObjectId(string: task.id)) ?? ObjectId.generate()
        entity.title = task.title
        entity.startDate = task.startDate
        entity.dueDate = task.dueDate
        entity.estimateHour = task.estimateHour
        entity.priority = task.priority.rawValue
        entity.category = task.category.rawValue
        entity.status = task.status.rawValue
        entity.brief = task.brief
        entity.detail = task.detail
        entity.assignees.append(objectsIn: task.assignees ?? [])
        entity.progress = task.progress
        entity.isCompleted = task.isCompleted
        entity.createdAt = task.createdAt
        entity.position = task.position
        entity.attachments.append(objectsIn: task.attachments ?? [])
        entity.parentId = task.parentId
        return entity
    }
    
    private func task(from entity: TaskEntity) -> TaskModel {
        return TaskModel(id: entity.id.stringValue,
                    title: entity.title,
                    startDate: entity.startDate,
                    dueDate: entity.dueDate,
                    estimateHour: entity.estimateHour,
                    priority: TaskPriority(rawValue: entity.priority) ?? .medium,
                    category: TaskCategory(rawValue: entity.category) ?? .others,
                    status: TaskStatus(rawValue: entity.status) ?? .backlog,
                    brief: entity.brief,
                    detail: entity.detail,
                    assignees: Array(entity.assignees),
                    progress: entity.progress,
                    isCompleted: entity.isCompleted,
                    position: entity.position,
                    createdAt: entity.createdAt,
                    parentId: entity.parentId)
    }
}
