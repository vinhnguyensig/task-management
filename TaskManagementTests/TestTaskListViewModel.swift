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
        mockTaskManagerDB = TaskManagerDB()
        viewModel = TaskListViewModel(taskManager: mockTaskManagerDB)
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
    
    func testToggleTaskCompletion_Success() async {
        // Arrange
        let task = TaskModel(title: "Task to toggle", isCompleted: false, position: 1, createdAt: Date())
        mockTaskManagerDB.tasksToReturn = [task]
        
        await viewModel.fetchTasks()

        // Act
        await viewModel.toggleTaskCompletion(task: task)

        // Assert
        let updatedTask = await viewModel.tasks.first
        XCTAssertEqual(updatedTask?.isCompleted, true)
    }
    
    func testSortTasks_Success() async {
        // Arrange
        let task1 = TaskModel(title: "Task A", isCompleted: false, position: 2, createdAt: Date())
        let task2 = TaskModel(title: "Task B", isCompleted: false, position: 1, createdAt: Date())
        mockTaskManagerDB.tasksToReturn = [task1, task2]
        
        await viewModel.fetchTasks()
        
        // Act
        await viewModel.toggleSortOrder() // Switch to ascending order
        await viewModel.toggleSortCriteria(.position) // Sort by position
        
        // Assert
        let sortedTaskTitles = await viewModel.tasks.map { $0.title }
        XCTAssertEqual(sortedTaskTitles, ["Task B", "Task A"])
    }

    func testFetchTasks_Error() async {
        // Arrange
        mockTaskManagerDB.errorToReturn = NSError(domain: "TestError", code: 500, userInfo: nil)

        // Act
        await viewModel.fetchTasks()

        // Assert
        let errorMessage = await viewModel.errorMessage
        XCTAssertNotNil(errorMessage)
        XCTAssertEqual(errorMessage, "Failed to load tasks: The operation couldn’t be completed. (TestError error 500.)")
    }
}
