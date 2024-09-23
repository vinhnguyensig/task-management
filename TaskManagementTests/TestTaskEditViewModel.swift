//
//  TestTaskEditViewModel.swift
//  TaskManagementTests
//
//  Created by Vinh Nguyen on 23/9/24.
//

import XCTest
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

}
