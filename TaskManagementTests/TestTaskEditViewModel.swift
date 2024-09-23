//
//  TestTaskEditViewModel.swift
//  TaskManagementTests
//
//  Created by Vinh Nguyen on 23/9/24.
//

import XCTest
import Combine
@testable import TaskManagement

final class TestTaskEditViewModel: XCTestCase {
    var viewModel: TaskEditViewModel!
    var mockManagerDB: TaskManagerDB!
    
    @MainActor override func setUp() {
        super.setUp()
        mockManagerDB = TaskManagerDB()
        viewModel = TaskEditViewModel(taskManager: mockManagerDB)
    }
    
    override func tearDown() {
        viewModel = nil
        mockManagerDB = nil
        super.tearDown()
    }
    
    // Test adding a task successfully
    @MainActor func testAddTaskSuccess() {
        let expectation = self.expectation(description: "Task added successfully")
        
        viewModel.$addedTask
            .dropFirst() // Drop the initial nil value
            .sink { addedTask in
                XCTAssertNotNil(addedTask)
                XCTAssertEqual(addedTask?.title, "Test Task")
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.addTask(title: "Test Task")
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Test adding a task with an error
    @MainActor func testAddTaskFailure() {
        mockManagerDB.errorToReturn = NSError(domain: "TestError", code: 500, userInfo: nil)
        let expectation = self.expectation(description: "Error message received")
        
        viewModel.$errorMessage
            .dropFirst() // Drop the initial nil value
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.addTask(title: "Test Task")
        waitForExpectations(timeout: 1.0, handler: nil)
    }
    
    // Test updating a task successfully
    @MainActor func testUpdateTaskSuccess() {
        let expectation = self.expectation(description: "Task updated successfully")
        
        let taskToUpdate = TaskModel(id: "1", title: "Initial Task")
        mockManagerDB.tasksToReturn = [taskToUpdate]
        
        viewModel.$updatedTask
            .dropFirst() // Drop the initial nil value
            .sink { updatedTask in
                XCTAssertNotNil(updatedTask)
                XCTAssertEqual(updatedTask?.title, "Updated Task")
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.updateTask(id: "1", title: "Updated Task")
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    // Test updating a task with an error
    @MainActor func testUpdateTaskFailure() {
        mockManagerDB.errorToReturn = NSError(domain: "TestError", code: 500, userInfo: nil)
        let expectation = self.expectation(description: "Error message received")
        
        let taskToUpdate = TaskModel(id: "1", title: "Initial Task")
        mockManagerDB.tasksToReturn = [taskToUpdate]
        
        viewModel.$errorMessage
            .dropFirst() // Drop the initial nil value
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                expectation.fulfill()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.updateTask(id: "1", title: "Updated Task")
        waitForExpectations(timeout: 1.0, handler: nil)
    }
}
