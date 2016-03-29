//
//  MSGTaskListTableViewControllerUITests.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/25/16.
//  Copyright © 2016 Sogeti USA. All rights reserved.
//

import XCTest

class MSGTaskListTableViewControllerUITests: XCTestCase {
    
    // MARK: - Class Constants
    static let offsetForTomorrow: NSTimeInterval = 86400.0 // In seconds
    static let offsetForDayAfterTomorrow: NSTimeInterval = 2 * MSGTaskListTableViewControllerUITests.offsetForTomorrow // In seconds
    static let aShortWhile: UInt32 = 5 // In seconds
    
    // MARK: - Stored Properties
    let app = XCUIApplication()
    
    // MARK: - Class setUp & tearDown
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
    
    // MARK: - Private Utility Methods
    // Create a task to be used by other test methods
    private func addTaskToList(taskTitleString: String) {
        
        // Select the `New` button from the main UI
        app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"].buttons["New"].tap()
        
        // Select the `Title` textField from the CreateAndEdit UI
        let textField = app.scrollViews.otherElements.textFields["Title:"] // Had to add 'Title:' identifier under Accessibility on the Storyboard
        textField.tap()
    
        // Enter text into the `Title` textField
        textField.typeText(taskTitleString)
        
        // Select the `Apply` button in the Navigation Bar of the CreateAndEdit UI
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
    }
    
    private func setDueDate(foundNewTask: XCUIElement) {
        foundNewTask.tap()
        
        // When
        app.scrollViews.otherElements.textFields["Due Date:"].tap() // Had to add 'Due Date:' identifier under Accessibility on the Storyboard
        
        // Tap anywhere to dismiss the due date picker popover
        app.scrollViews.otherElements.staticTexts["Title:"].tap() // Had to add 'Title:' identifier under Accessibility on the Storyboard
        
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
    }
    
    // Ensure that enough time has elapsed so that auto-generated timestamps are not identical
    private func sleepUntilNextMinute() {
        let startMinutes = NSCalendar.currentCalendar().components([.Minute], fromDate: NSDate()).minute
        var incrementedMinutes: Int
        repeat {
            sleep(MSGTaskListTableViewControllerUITests.aShortWhile)
            incrementedMinutes = NSCalendar.currentCalendar().components([.Minute], fromDate: NSDate()).minute
        } while startMinutes == incrementedMinutes
    }
    
    private func taskDateFromString (taskPrefixString: String, taskDateString: String) -> NSDate? {
        // Crop task prefix from the string
        var croppedTaskDateString = taskDateString
        
        if let rangeOfPrefix = croppedTaskDateString.rangeOfString(taskPrefixString) {
            let indexFollowingPrefix = rangeOfPrefix.endIndex
            croppedTaskDateString = croppedTaskDateString.substringFromIndex(indexFollowingPrefix)
        }
        
        let taskDateFormatter = NSDateFormatter()
        taskDateFormatter.dateStyle = .ShortStyle //Match the style that was used to create the date string
        taskDateFormatter.timeStyle = .ShortStyle
        return taskDateFormatter.dateFromString(croppedTaskDateString)
    }
    
    // MARK: - Test Methods
    func test1_1AddNewTaskToTaskList() {
        
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
    
    func test1_2DeleteTaskFromList() {
        
        // Given
        // Assure that there is a task available to delete
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithDateString)
        
        // Find the last element in the tableView
        let cells = app.tables.cells
        let cellCount = cells.count

        // Find the last cell in the list
        let lastCellElement = cells.elementBoundByIndex(cells.count - 1)
        
        // When
        // Swipe/Delete
        lastCellElement.swipeLeft()
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
        setDueDate(foundNewTask)
        
        // Then
        // New cells have the `Due Date` initialized to "Unset", this Due date should be something other than "Unset"
        let dueDateLabel = foundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Due Date:'")).element
        XCTAssertNotEqual(dueDateLabel.label, "Due Date: Unset")
   }
    
    func test2_2ModifyTaskStatus() {
        
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
    
    // The 'Status Date:' is only reset when a new status is selected
    func test2_3ModifyTaskStatusDate() {
        
        // Given
        // Ensure that there is at least one task in the list
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithDateString)
        
        let foundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(helloWithDateString)").element
        let statusDateLabel = foundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status Date:'")).element.label
        foundNewTask.tap()
        
        // When
        // The 'Status Date:' is only reset when a new status is selected.
        // The only way to automatically detect the change is when the minute component has changed
        // so a delay must be performed to allow a time interval for that to occur
        sleepUntilNextMinute()
        
        app.scrollViews.otherElements.buttons["Done"].tap()

        // Navigate back to home UI screen
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        
        let updatedStatusDateLabel = foundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status Date:'")).element.label

        // Then
        XCTAssertNotEqual(statusDateLabel, updatedStatusDateLabel)
    }
    
    func test3_1SelectSortByTitle() {
        
        // Given
        let helloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithDateString)
        
        let helloWithTomorrowDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(MSGTaskListTableViewControllerUITests.offsetForTomorrow), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(helloWithTomorrowDateString)
        
        let appNavigationBar = app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"]
        
        // When
        appNavigationBar.buttons["Sort"].tap()
        appNavigationBar.segmentedControls.buttons["Title"].tap()
        
        // Then
        let cells = app.tables.cells
        
        let firstCellElement = cells.containingType(.StaticText, identifier: "Title: \(helloWithDateString)").element
        let firstCellTitle = firstCellElement.staticTexts["Title:"].label

        let secondCellElement = cells.containingType(.StaticText, identifier: "Title: \(helloWithTomorrowDateString)").element
        let secondCellTitle = secondCellElement.staticTexts["Title:"].label
        
        XCTAssertTrue(firstCellTitle <= secondCellTitle)
    }
    
    func test3_2SelectSortByDueDate() {
        
        // Given
        let firstHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(firstHelloWithDateString)
        let firstFoundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(firstHelloWithDateString)").element
        
        let secondHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(MSGTaskListTableViewControllerUITests.offsetForTomorrow), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(secondHelloWithDateString)
        let secondFoundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(secondHelloWithDateString)").element
        
        let appNavigationBar = app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"]
        
        // When
        setDueDate(firstFoundNewTask)
        let firstCellDueDateString = firstFoundNewTask.staticTexts["Due Date:"].label
        guard let firstCellDueDate = taskDateFromString("Due Date: ", taskDateString: firstCellDueDateString) else { XCTFail(); return }
        
        sleepUntilNextMinute()
        
        setDueDate(secondFoundNewTask)
        let secondCellDueDateString = secondFoundNewTask.staticTexts["Due Date:"].label 
        guard let secondCellDueDate = taskDateFromString("Due Date: ", taskDateString: secondCellDueDateString) else { XCTFail(); return }

        // Then
        appNavigationBar.buttons["Sort"].tap()
        appNavigationBar.segmentedControls.buttons["Due Date"].tap()
        
        XCTAssertTrue(firstCellDueDate.compare(secondCellDueDate) == .OrderedAscending)
    }
    
    func test3_3SelectSortByStatus() {
        
        // Given
        let firstHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(firstHelloWithDateString)
        let firstFoundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(firstHelloWithDateString)").element
        
        let secondHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(MSGTaskListTableViewControllerUITests.offsetForTomorrow), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(secondHelloWithDateString)
        let secondFoundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(secondHelloWithDateString)").element
        
        let thirdHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(MSGTaskListTableViewControllerUITests.offsetForDayAfterTomorrow), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(thirdHelloWithDateString)
        let thirdFoundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(thirdHelloWithDateString)").element
        
        let appNavigationBar = app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"]
        
        // When
        // When a task is created, the 'Status:' is `New` by default
        let firststatusLabel = firstFoundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status:'")).element.label
        
        secondFoundNewTask.tap()
        app.scrollViews.otherElements.buttons["Done"].tap()
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        let secondStatusLabel = secondFoundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status:'")).element.label
        
        thirdFoundNewTask.tap()
        app.scrollViews.otherElements.buttons["Canceled"].tap()
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        let thirdStatusLabel = thirdFoundNewTask.staticTexts.matchingPredicate(NSPredicate(format: "label BEGINSWITH 'Status:'")).element.label
        
        // Then
        appNavigationBar.buttons["Sort"].tap()
        appNavigationBar.segmentedControls.buttons["Status"].tap()
        
//        XCTAssertTrue(firstCellDueDate <= secondCellDueDate)
    }
    
    func test3_4SelectSortByStatusDate() {
        
        // Given
        let firstHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(firstHelloWithDateString)
        let firstFoundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(firstHelloWithDateString)").element
        
        sleepUntilNextMinute() // This ensures that the second task will have a later Status Date
        
        let secondHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(MSGTaskListTableViewControllerUITests.offsetForTomorrow), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(secondHelloWithDateString)
        let secondFoundNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(secondHelloWithDateString)").element
        
        let appNavigationBar = app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"]
        
        // When
        let firstCellStatusDateString = firstFoundNewTask.staticTexts["Status Date:"].label
        guard let firstCellStatusDate = taskDateFromString("Status Date: ", taskDateString: firstCellStatusDateString) else { XCTFail(); return }
        
        let secondCellStatusDateString = secondFoundNewTask.staticTexts["Status Date:"].label
        guard let secondCellStatusDate = taskDateFromString("Status Date: ", taskDateString: secondCellStatusDateString) else { XCTFail(); return }
        
        // Then
        appNavigationBar.buttons["Sort"].tap()
        appNavigationBar.segmentedControls.buttons["Status Date"].tap()
        
        XCTAssertTrue(firstCellStatusDate.compare(secondCellStatusDate) == .OrderedAscending)
    }
}
