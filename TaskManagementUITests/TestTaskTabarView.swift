//
//  TestTaskTabarView.swift
//  TaskManagementUITests
//
//  Created by Vinh Nguyen on 24/9/24.
//

import XCTest

final class TestTaskTabarView: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        do {
            try super.setUpWithError()
            continueAfterFailure = false
            app.launch()
        } catch {
            
        }
    }
    
    func tabbarButtons() {
        app.buttons["homeButton"].tap()
        XCTAssertTrue(app.otherElements["homeTab"].exists, "Home Tab should be displayed")
        
        app.buttons["calendarButton"].tap()
        XCTAssertTrue(app.otherElements["calendarTab"].exists, "Calendar Tab should be displayed")
        
        app.buttons["menuButton"].tap()
        XCTAssertTrue(app.otherElements["menuTab"].exists, "Menu Tab should be displayed")
        
        app.buttons["tasksButton"].tap()
        XCTAssertTrue(app.otherElements["tasksTab"].exists, "Tasks Tab should be displayed")
    }
    
    override func tearDown() {
    }
}
