//
//  MSGCreateAndEditViewControllerUITests.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/31/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import XCTest

class MSGCreateAndEditViewControllerUITests: XCTestCase {
        
    // MARK: - Stored Properties
    let app = XCUIApplication()
    
    // MARK: - Class setUp & tearDown
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        removeAllTasksFromTaskList()
        
        createAndEnterATask()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // MARK: - Private Utility Methods
    private func createAndEnterATask() {
        // Select the `New` button from the main UI
        app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"].buttons["New"].tap()
        
        // Enter text into the `Title` textField
        let saveDateString = "\(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        let helloWithDateString = "Hello \(saveDateString)"
        let titleTextField = app.scrollViews.otherElements.textFields["Title:"]
        titleTextField.tap()
        titleTextField.typeText(helloWithDateString)
        app.buttons["Return"].tap()
        
        // Enter text into the `Description` textField
        let descriptionString = "This is a description string"
        let descriptionTextView = app.scrollViews.otherElements.textViews["Description:"]
        descriptionTextView.tap()
        descriptionTextView.typeText(descriptionString)
        app.scrollViews.element.swipeDown()
        
        // Enter a date for the `Due Date`
        app.scrollViews.otherElements.textFields["Due Date:"].tap() // Had to add 'Due Date:' identifier under Accessibility on the Storyboard
        
        // Tap anywhere to dismiss the due date picker popover
        app.scrollViews.otherElements.staticTexts["Title:"].tap() // Had to add 'Title:' identifier under Accessibility on the Storyboard

        // Set a non-default value for the `Status` segmented control
        app.scrollViews.otherElements.buttons["Done"].tap()
    }
    
    private func removeAllTasksFromTaskList() {
        // Find the last element in the tableView
        let cells = app.tables.cells
        
        while cells.count > 0 {
            cells.elementBoundByIndex(0).swipeLeft()
            app.tables.buttons["Delete"].tap()
        }
    }
    
    func testClearTask() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
