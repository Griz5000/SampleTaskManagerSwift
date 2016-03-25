//
//  MSGTaskListTableViewControllerUITests.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/25/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import XCTest

class MSGTaskListTableViewControllerUITests: XCTestCase {
            
    let app = XCUIApplication()
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        XCUIDevice.sharedDevice().orientation = .Portrait
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Create a task to be used by other test methods
    func addTaskToList(taskTitleString: String) { // √
        
        // Select the `New` button from the main UI
        app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"].buttons["New"].tap()
        
        // Select the `Title` textField from the CreateAndEdit UI
        let textFieldArray = app.scrollViews.descendantsMatchingType(.TextField)
        let textField = textFieldArray["Title:"]
        textField.tap()
        
        // Enter text into the `Title` textField
        textField.typeText(taskTitleString)
        
        // Select the `Apply` button in the Navigation Bar of the CreateAndEdit UI
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
    }
    
    func test1_1AddNewTaskToTaskList() { // √
        
        // Given
        // When
        let saveDateString = "\(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        let helloWithDateString = "Hello \(saveDateString)"
        addTaskToList(helloWithDateString)
        
        // Then
        // Back on the main UI, Assure that the new task exists in the tableView
        let foundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(helloWithDateString)").element
        XCTAssertEqual(foundNewTask.exists, true)
        
        // New cells have the `Due Date` initialized to "Unset"
        let dueDateLabel = foundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Due Date:'")).element
        XCTAssertEqual(dueDateLabel.label, "Due Date: Unset")
        
        // New cells have the `Status` initialized to "New"
        let statusLabel = foundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status:'")).element
        XCTAssertEqual(statusLabel.label, "Status: New")
        
        // New cells have the `Status Date` initialized to the date the task was created
        let statusdateLabel = foundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status Date:'")).element
        XCTAssertEqual(statusdateLabel.label, "Status Date: \(saveDateString)")
    }
    
    func test1_2DeleteTaskFromList() { // √
        
        // Given
        // Assure that there is a task available to delete
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        
        addTaskToList(helloWithDateString)
        
        // Find the last element in the tableView
        let cells = app.tables.cells
        let cellCount = cells.count

        // Find the last cell in the list
        let titleStringElement = cells.elementBoundByIndex(cells.count - 1)
        
        // When
        // Swipe/Delete
        titleStringElement.swipeLeft()
        app.tables.buttons["Delete"].tap()
        
        // Then
        XCTAssertEqual(cells.count, cellCount - 1)
    }
    
    func test2_1ModifyTaskDueDate() {
        
        // Given
        // Ensure that there is at least one task in the list
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithDateString)
        
        let foundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(helloWithDateString)").element
        foundNewTask.tap()

        // When
        
        // Then
    }
    
    func test2_2ModifyTaskStatus() { // √
        
        // Given
        // Ensure that there is at least one task in the list
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithDateString)
        
        let foundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(helloWithDateString)").element
        foundNewTask.tap()
        
        // When
        app.scrollViews.otherElements.buttons["Done"].tap()
        
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        
        // Then
        let statusLabel = foundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status:'")).element
        
        XCTAssertEqual(statusLabel.label, "Status: Done")
        
        // When
        foundNewTask.tap()
        
        app.scrollViews.otherElements.buttons["Canceled"].tap()
        
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        
        // Then
        // It is not neccessary to refetch `statusLabel`, it happens automatically
        XCTAssertEqual(statusLabel.label, "Status: Canceled")
    }
    
    func test2_3ModifyTaskStatusDueDate() {
        
        // Given
        
        // Ensure that there is at least one task in the list
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithDateString)
        
        // When
        
        // Then
    }
    
    func tes3_1SelectSortByTitle() {
        
        // Given
        
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithDateString)
        let helloWithTomorrowDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(86400), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithTomorrowDateString)
        
        let appNavigationBar = app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"]
        
        // When
        appNavigationBar.buttons["Sort"].tap()
        appNavigationBar.segmentedControls.buttons["Title"].tap()
        
        // Then
        let cells = app.tables.cells
        let firstCellElement = cells.elementBoundByIndex(0)
        let secondCellElement = cells.elementBoundByIndex(1)
        
        XCTAssertTrue(firstCellElement.label <= secondCellElement.label)
    }
    
    func test3_2SelectSortByDueDate() {
        
        // Given
        
        // When
        
        // Then
    }
    
    func test3_3SelectSortByStatus() {
        
        // Given
        
        // When
        
        // Then
    }
    
    func test3_4SelectSortByStatusDate() {
        
        // Given
        
        // When
        
        // Then
    }
    
//    func testModifyExistingTask() {
//        
//        // Given
//        
//        // Ensure that there is at least one task in the list
//        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
//        
//        addTaskToList(helloWithDateString)
//        
//        // When
//        let cells = app.tables.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Title: Hello'"))
//        let firstCell = cells.elementBoundByIndex(0)
//        firstCell.tap()
//        
//        let titleElementsQuery = app.scrollViews.otherElements.containingType(.StaticText, identifier:"Title:")
//        let element = titleElementsQuery.childrenMatchingType(.Other).element
//        
//        // 1
//        let textView = element.childrenMatchingType(.TextView).element
//        textView.tap()
//        textView.typeText("My name is Mike")
//        
//        // 2
//        titleElementsQuery.childrenMatchingType(.TextField).elementBoundByIndex(1).tap()
//        app.datePickers.pickerWheels["Today"].tap()
//        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Image).elementBoundByIndex(0).tap()
//        
//        // 3
//        app.scrollViews.otherElements.buttons["Done"].tap()
//        
//        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
//        
//        // Then
//        let firstCellInTaskList = app.tables.cells.elementBoundByIndex(0)
//        let statusLabel = firstCellInTaskList.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status:'")).element
//        
//        XCTAssertEqual(statusLabel.label, "Status: Done")
//    }
}
