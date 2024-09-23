//
//  TestTaskListViewModel.swift
//  TaskManagementTests
//
//  Created by Vinh Nguyen on 23/9/24.
//

import XCTest

@testable import TaskManagement

final class TestTaskListViewModel: XCTestCase {
    var viewModel: TaskListViewModel!
    var mockTaskManagerDB: TaskManagerDB!
    
    @MainActor override func setUp() {
        super.setUp()
        
        mockTaskManagerDB = TaskManagerDB.shared
        if let taskManager = mockTaskManagerDB {
            viewModel = TaskListViewModel(taskManager: taskManager)
        }
    }
    
    override func tearDown() {
        viewModel = nil
        mockTaskManagerDB = nil
        super.tearDown()
    }
    
    func testFetchTasks_Success() async {
        let tasks = [TaskModel(title: "Task Unit Test 1", isCompleted: false, position: 1, createdAt: Date())]
       mockTaskManagerDB.tasksToReturn = tasks

       await viewModel.fetchTasks()

       let taskCount = await viewModel.tasks.count
       let taskTitle = await viewModel.tasks.first?.title

       XCTAssertEqual(taskCount, 1)
       XCTAssertEqual(taskTitle, "Task Unit Test 1")
   }
    
    func testDeleteTask_Success() async {
        // Arrange
        let task = TaskModel(title: "Test task to delete", isCompleted: false, position: 1, createdAt: Date())
        mockTaskManagerDB.tasksToReturn = [task]
        
        await viewModel.fetchTasks()
        let initialTaskCount = await viewModel.tasks.count

        // Act
        await viewModel.deleteTask(at: IndexSet(integer: 0))

        // Assert
        let taskCount = await viewModel.tasks.count
        XCTAssertEqual(initialTaskCount, 1)
        XCTAssertEqual(taskCount, 0)
    }

}
