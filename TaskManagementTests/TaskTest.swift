//
//  TaskTest.swift
//  TaskManagementTests
//
//  Created by Vinh Nguyen on 9/9/24.
//

import XCTest

import XCTest
@testable import TaskManagement

class TaskTests: XCTestCase {

    // Test that a task initializes with required and optional values correctly
    func testTaskInitialization() {
        let title = "Test Task"
        let startDate = Date()
        let dueDate = Date().addingTimeInterval(3600)
        let estimateHour = 2.5
        let priority = TaskPriority.high
        let category = TaskCategory.work
        let description = "This is a test task"
        let detail = "Details of the task"
        let assignees = ["Vinh", "Ken"]
        
        let task = Task(title: title,
                        startDate: startDate,
                        dueDate: dueDate,
                        estimateHour: estimateHour,
                        priority: priority,
                        category: category,
                        brief: description,
                        detail: detail,
                        assignees: assignees)
        
        XCTAssertEqual(task.title, title)
        XCTAssertEqual(task.startDate, startDate)
        XCTAssertEqual(task.dueDate, dueDate)
        XCTAssertEqual(task.estimateHour, estimateHour)
        XCTAssertEqual(task.priority, priority)
        XCTAssertEqual(task.category, category)
        XCTAssertEqual(task.brief, description)
        XCTAssertEqual(task.detail, detail)
        XCTAssertEqual(task.assignees, assignees)
        XCTAssertEqual(task.isCompleted, false) // Default value
        XCTAssertNotNil(task.createdAt)
    }
    
    // Test that optional properties can be nil
    func testTaskInitializationWithNilValues() {
        let title = "Test Task"
        let task = Task(title: title)
        
        XCTAssertEqual(task.title, title)
        XCTAssertNil(task.startDate)
        XCTAssertNil(task.dueDate)
        XCTAssertNil(task.estimateHour)
        XCTAssertNil(task.priority)
        XCTAssertNil(task.category)
        XCTAssertNil(task.brief)
        XCTAssertNil(task.detail)
        XCTAssertNil(task.assignees)
        XCTAssertEqual(task.isCompleted, false)
    }
    
    // Test default `isCompleted` value is false
    func testTaskDefaultCompletionStatus() {
        let task = Task(title: "Incomplete Task")
        
        XCTAssertFalse(task.isCompleted)
    }
    
    // Test updating `isCompleted` status
    func testTaskCompletionStatusUpdate() {
        var task = Task(title: "Task to complete")
        
        XCTAssertFalse(task.isCompleted)
        
        task.isCompleted = true
        
        XCTAssertTrue(task.isCompleted)
    }
    
    // Test creation date is assigned automatically
    func testTaskCreationDate() {
        let beforeCreation = Date()
        let task = Task(title: "Task with auto creation date")
        let afterCreation = Date()
        
        XCTAssertGreaterThanOrEqual(task.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(task.createdAt, afterCreation)
    }
    
    // Test task with assignees list
    func testTaskAssignees() {
        let task = Task(title: "Team Task", assignees: ["Vinh", "Ken"])
        
        XCTAssertEqual(task.assignees?.count, 2)
        XCTAssertEqual(task.assignees, ["Vinh", "Ken"])
    }
}
