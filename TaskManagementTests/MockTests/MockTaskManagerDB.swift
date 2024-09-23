//
//  MockTaskManagerDB.swift
//  TaskManagementTests
//
//  Created by Vinh Nguyen on 23/9/24.
//

import Foundation

class TaskManagerDB: TaskManagerDBProtocol {
    static let shared = TaskManagerDB()
    
    private init() {}
    
    var tasksToReturn: [TaskModel] = []
    var errorToReturn: Error?
    
    func fetchTasks(by category: String, completion: @escaping (Result<[TaskModel], Error>) -> Void) {
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            completion(.success(tasksToReturn))
        }
    }
    
    func fetchTasks(status: String, isToday: Bool, category: String?, completion: @escaping (Result<[TaskModel], any Error>) -> Void) {
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            completion(.success(tasksToReturn))
        }
    }
    
    func fetchTodayTasks(completion: @escaping (Result<[TaskModel], any Error>) -> Void) {
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            completion(.success(tasksToReturn))
        }
    }
    
    func getAllTasks(completion: @escaping (Result<[TaskModel], any Error>) -> Void) {
        if let error = errorToReturn {
            completion(.failure(error))
        } else {
            completion(.success(tasksToReturn))
        }
    }
    
    func deleteTask(task: TaskModel, completion: @escaping ((any Error)?) -> Void) {
        if let error = errorToReturn {
            completion(error)
        } else {
            if let index = tasksToReturn.firstIndex(where: { $0.id == task.id }) {
                tasksToReturn.remove(at: index)
                completion(nil)  // No error, so return nil
            } else {
                completion(NSError(domain: "TaskNotFound", code: 404, userInfo: nil))  // Simulate task not found
            }
        }
    }
    
    func updateTaskPositions(_ tasks: [TaskModel], completion: @escaping ((any Error)?) -> Void) {
        if let error = errorToReturn {
            completion(error)
        } else {
            for updatedTask in tasks {
                if let index = tasksToReturn.firstIndex(where: { $0.id == updatedTask.id }) {
                    tasksToReturn[index].position = updatedTask.position
                }
            }
            completion(nil)  // No error, so return nil
        }
    }
    
    func updateTask(task: TaskModel, completion: @escaping ((any Error)?) -> Void) {
        if let error = errorToReturn {
            completion(error)
        } else {
            if let index = tasksToReturn.firstIndex(where: { $0.id == task.id }) {
                tasksToReturn[index] = task
                completion(nil)  // No error, so return nil
            } else {
                completion(NSError(domain: "TaskNotFound", code: 404, userInfo: nil))  // Simulate task not found
            }
        }
    }
}
