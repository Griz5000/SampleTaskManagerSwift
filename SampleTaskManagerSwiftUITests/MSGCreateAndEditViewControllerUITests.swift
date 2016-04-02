//
//  MSGCreateAndEditViewControllerUITests.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/31/16.
//  Copyright © 2016 Sogeti USA. All rights reserved.
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
        
        SampleTaskManagerSwiftUITestsUtilities.removeAllTasksFromTaskList()
        
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
        app.scrollViews.otherElements.textFields["Due Date:"].tap()
        
        // Tap anywhere to dismiss the due date picker popover
        app.scrollViews.otherElements.staticTexts["Title:"].tap()
        
        // Set a non-default value for the `Status` segmented control
        app.scrollViews.otherElements.buttons["Done"].tap()
    }
    
    // MARK: - Test Methods
    func test1_1ClearNewTask() {

        // Given
        let statusMatchingDateString = "\(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        
        // When
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Clear"].tap()
        
        // Then
        // Verify that the `Title` is empty, only for a new Task
        let titleTextField = app.scrollViews.otherElements.textFields["Title:"]
        let titleTextFieldString = titleTextField.value as! String
        XCTAssertTrue(titleTextFieldString.isEmpty)

        // Verify that the `Description` is empty
        let descriptionTextView = app.scrollViews.otherElements.textViews["Description:"]
        let descriptionTextViewString = descriptionTextView.value as! String
        XCTAssertTrue(descriptionTextViewString.isEmpty)
        
        // Verify that the `Due Date` is blank
        let dueDateTextField = app.scrollViews.otherElements.textFields["Due Date:"]
        let dueDateTextFieldString = dueDateTextField.value as! String
        XCTAssertTrue(dueDateTextFieldString.isEmpty)
        
        // Verify that the `Status` is New
        let newButtonSelected = app.scrollViews.otherElements.segmentedControls.buttons["New"].selected
        let doneButtonSelected = app.scrollViews.otherElements.segmentedControls.buttons["Done"].selected
        let canceledButtonSelected = app.scrollViews.otherElements.segmentedControls.buttons["Canceled"].selected
        
        XCTAssertTrue(newButtonSelected)
        XCTAssertFalse(doneButtonSelected)
        XCTAssertFalse(canceledButtonSelected)
        
        // Verify that the `Status Date` matches the current date
        let statusDateTextField = app.scrollViews.otherElements.textFields["Status Date:"]
        let statusDateTextFieldString = statusDateTextField.value as! String
        XCTAssertEqual(statusDateTextFieldString, statusMatchingDateString)
    }
    
    func test1_2ClearExistingTask() {
        
        // Given
        // When
        // Return to the main UI
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        // Select the first table view cell
        let foundElement = app.tables.cells.elementBoundByIndex(0)
        foundElement.tap()

        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Clear"].tap()
        
        // Then
        // Verify that the `Title` is not empty, only for an existing Task
        let titleTextField = app.scrollViews.otherElements.textFields["Title:"]
        let titleTextFieldString = titleTextField.value as! String
        XCTAssertFalse(titleTextFieldString.isEmpty)
    }
    
    func test1_3ApplyWithEmptyTitle() {
        // Given
        // When
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Clear"].tap()

        // Then
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        XCTAssertTrue(app.alerts["Title Not Set"].exists)
        app.alerts["Title Not Set"].collectionViews.buttons["No"].tap()
        XCTAssertFalse(app.alerts["Title Not Set"].exists)
        
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        app.alerts["Title Not Set"].collectionViews.buttons["Yes"].tap()
        
        XCTAssertTrue(app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"].exists)
    }
    
    func test1_4FailDueDateValidation() {
        
        // Given
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()

        // When
        // This time of due date validation failure only occurs with New tasks
        app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"].buttons["New"].tap()

        // Add a title to the new task
        let titleTextField = app.scrollViews.otherElements.textFields["Title:"]
        titleTextField.tap()
        titleTextField.typeText("FailDueDateValidation")
        app.buttons["Return"].tap()

        // Set the due date for the new task to be "back in time"
        let elementsQuery = app.scrollViews.otherElements
        elementsQuery.textFields["Due Date:"].tap()
        app.datePickers.pickerWheels["Today"].swipeDown()
        elementsQuery.staticTexts["Title:"].tap()
        
        // Then
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        XCTAssertTrue(app.alerts["Invalid Due Date"].exists)
        
        app.alerts["Invalid Due Date"].collectionViews.buttons["Ok"].tap()
        XCTAssertTrue(app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].exists)
    }
}
