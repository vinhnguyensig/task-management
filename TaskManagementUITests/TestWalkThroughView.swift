//
//  TestWalkThroughView.swift
//  TaskManagementUITests
//
//  Created by Vinh Nguyen on 24/9/24.
//

import XCTest
import SwiftUI

@testable import TaskManagement

extension XCUIApplication {
    func setSeenWalkThrough(_ isReopenApp: Bool = true) {
        launchArguments += ["-ReopenApp", isReopenApp ? "true" : "false"]
    }
}

final class TestWalkThroughView: XCTestCase {
    
    let app = XCUIApplication()
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = true
        app.setSeenWalkThrough(false)
        app.launch()
    }
    
    func testWalkthroughNavigation() throws {
        
        // Wait for the first "Next" button to appear
        let nextButton = app.buttons["nextButton"]
        let exists = NSPredicate(format: "exists == true")
        
        expectation(for: exists, evaluatedWith: nextButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        XCTAssertTrue(nextButton.exists, "Next button should be visible at the start")
        
        // Tap through the walkthrough pages
        for index in 0..<6 {
            XCTAssertTrue(nextButton.exists, "Next button should be visible on page \(index)")
            nextButton.tap()
        }
        
        // Assert that the button has changed to "Get Started" on the last page
        XCTAssertEqual(nextButton.label, "Get Started", "Button should change to 'Get Started' on the last page")
        
        // Tap "Get Started"
        nextButton.tap()
        
        // Wait for the button to disappear after the navigation
        expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: nextButton, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        
        // Assert that the WalkthroughView is no longer visible
        XCTAssertFalse(nextButton.exists, "WalkthroughView should no longer be visible after tapping 'Get Started'")
    }
    
    override func tearDown() {
        super.tearDown()
    }
}
