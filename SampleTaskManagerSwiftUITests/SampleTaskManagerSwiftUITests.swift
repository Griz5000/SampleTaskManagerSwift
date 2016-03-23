//
//  SampleTaskManagerSwiftUITests.swift
//  SampleTaskManagerSwiftUITests
//
//  Created by Michael Grysikiewicz on 3/7/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import XCTest

class SampleTaskManagerSwiftUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        XCUIDevice.sharedDevice().orientation = .Portrait
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Create a task to be used by other test methods
    func addTaskToList() -> String {

        let app = XCUIApplication()
        
        // Select the `New` button from the main UI
        app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"].buttons["New"].tap()
        
        // Select the `Title` textField from the CreateAndEdit UI
        let textField = app.scrollViews.otherElements.containingType(.StaticText, identifier:"Title:").childrenMatchingType(.TextField).elementBoundByIndex(0)
        textField.tap()
        
        // Enter text into the `Title` textField
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        textField.typeText(helloWithDateString)
        
        // Select the `Apply` button in the Navigation Bar of the CreateAndEdit UI
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        
        return helloWithDateString
    }
    
    func testAddNewTaskToTaskList() {
        
        // Given
        let app = XCUIApplication()
        
        // When
        let helloWithDateString = addTaskToList()
        
        // Back on the main UI, find the last element in the tableView
        let cells = app.tables.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Title: Hello'"))
        let titleStringElement = cells.elementBoundByIndex(cells.count - 1)
        
        // Then
        // Assure that the text entered for the `Title` textField matches the text displayed in the tableView
        XCTAssertEqual(titleStringElement.label, "Title: \(helloWithDateString)")
    }
    
    func testModifyExistingTask() {
        
        // Given
        let app = XCUIApplication()
        
        // Ensure that there is at least one task in the list
        addTaskToList()
        
        // When
        let cells = app.tables.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Title: Hello'"))
        let firstCell = cells.elementBoundByIndex(0)
        firstCell.tap()
        
        let titleElementsQuery = app.scrollViews.otherElements.containingType(.StaticText, identifier:"Title:")
        let element = titleElementsQuery.childrenMatchingType(.Other).element
        
        let textView = element.childrenMatchingType(.TextView).element
        textView.tap()
        textView.typeText("My name is Mike")
        
        titleElementsQuery.childrenMatchingType(.TextField).elementBoundByIndex(1).tap()
        app.datePickers.pickerWheels["Today"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Image).elementBoundByIndex(0).tap()
        app.scrollViews.otherElements.buttons["Done"].tap()
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        
        // Then
        let firstCellInTaskList = app.tables.cells.elementBoundByIndex(0)
        let statusLabel = firstCellInTaskList.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status:'")).element
        
        XCTAssertEqual(statusLabel.label, "Status: Done")
    }
    
    func testDeleteFirstTask() {
  
        // Given
        let app = XCUIApplication()
        
        addTaskToList()

        // Find the last element in the tableView
        let cells = app.tables.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Title:'"))
        let cellCount = cells.count
        let titleStringElement = cells.elementBoundByIndex(cells.count - 1)
        
        // When
        // Swipe/Delete
        titleStringElement.swipeLeft()
        XCUIApplication().tables.buttons["Delete"].tap()
        
        XCTAssertEqual(cells.count, cellCount - 1)
    }
    
}
