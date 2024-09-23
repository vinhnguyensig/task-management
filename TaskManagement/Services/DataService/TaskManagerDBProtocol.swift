//
//  TaskManagerDBProtocol.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 23/9/24.
//

import Foundation

protocol TaskManagerDBProtocol {
    func fetchTasks(by category: String, completion: @escaping (Result<[TaskModel], Error>) -> Void)
    func fetchTasks(status: String, isToday: Bool, category: String?, completion: @escaping (Result<[TaskModel], Error>) -> Void)
    func fetchTodayTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void)
    func getAllTasks(completion: @escaping (Result<[TaskModel], Error>) -> Void)
    func deleteTask(task: TaskModel, completion: @escaping (Error?) -> Void)
    func updateTaskPositions(_ tasks: [TaskModel], completion: @escaping (Error?) -> Void)
    func updateTask(task: TaskModel, completion: @escaping (Error?) -> Void)
}
