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
    
    // NOTE: Due to not being allowed to access App data structures in UI Testing, the values for the TaskStatus enum are simulated
    static let MSGTask_TaskStatus_New: Int      = 0
    static let MSGTask_TaskStatus_Done: Int     = 1
    static let MSGTask_TaskStatus_Canceled: Int = 2
    
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
        
        removeAllTasksFromTaskList()
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
    
    private func cropLabelString(taskPrefixString: String, taskLabelString: String) -> String {
        var croppedTaskLabelString = taskLabelString
        
        if let rangeOfPrefix = taskLabelString.rangeOfString(taskPrefixString) {
            let indexFollowingPrefix = rangeOfPrefix.endIndex
            croppedTaskLabelString = croppedTaskLabelString.substringFromIndex(indexFollowingPrefix)
        }
        
        return croppedTaskLabelString
    }
    
    private func taskDateFromString(taskPrefixString: String, taskDateString: String) -> NSDate? {
        // Crop task prefix from the string
        let croppedTaskDateString = cropLabelString(taskPrefixString, taskLabelString: taskDateString)
        
        let taskDateFormatter = NSDateFormatter()
        taskDateFormatter.dateStyle = .ShortStyle //Match the style that was used to create the date string
        taskDateFormatter.timeStyle = .ShortStyle
        return taskDateFormatter.dateFromString(croppedTaskDateString)
    }
    
    private func removeAllTasksFromTaskList() {
        // Find the last element in the tableView
        let cells = app.tables.cells
        
        while cells.count > 0 {
            cells.elementBoundByIndex(0).swipeLeft()
            app.tables.buttons["Delete"].tap()
        }
    }
    
    // I could not use MSGTask.TaskStatus directly in the UI Testing, per link below
    private func taskStatusFromString(taskPrefixString: String, taskStatusString: String) -> Int? {

        /*
        https://github.com/Quick/Quick/issues/415#issuecomment-153885307
        esetnik commented on Nov 4, 2015
        I received a response from Apple regarding this issue.
        
        Apple Developer Relations04-Nov-2015 04:13 PM
        
        This issue behaves as intended based on the following:
        
        UI tests run outside your app in a separate process. You can’t access app code from inside a UI test - that’s intentionally part of the design. Use unit testing for tests that need to access the app code and UI tests to automate user interaction testing.
        
        We are now closing this bug report.
        */

        // Crop task prefix from the string
        let croppedTaskStatusString = cropLabelString(taskPrefixString, taskLabelString: taskStatusString)
     
        switch croppedTaskStatusString {
        case "New":
            return MSGTaskListTableViewControllerUITests.MSGTask_TaskStatus_New
        case "Done":
            return MSGTaskListTableViewControllerUITests.MSGTask_TaskStatus_Done
        case "Canceled":
            return MSGTaskListTableViewControllerUITests.MSGTask_TaskStatus_Canceled
        default:
            return nil
        }
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
        // Create the first task
        let firstCreatedHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(firstCreatedHelloWithDateString)
        let firstCreatedNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(firstCreatedHelloWithDateString)").element
        
        // Create the second task
        let secondCreatedHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(MSGTaskListTableViewControllerUITests.offsetForTomorrow), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(secondCreatedHelloWithDateString)
        let secondCreatedNewTask = app.tables.cells.containingType(.StaticText, identifier: "Title: \(secondCreatedHelloWithDateString)").element
        
        // Create the third task
        let thirdCreatedHelloWithDateString = "Hello \(NSDateFormatter.localizedStringFromDate(NSDate().dateByAddingTimeInterval(MSGTaskListTableViewControllerUITests.offsetForDayAfterTomorrow), dateStyle: .ShortStyle, timeStyle: .ShortStyle))"
        addTaskToList(thirdCreatedHelloWithDateString)
        
        let appNavigationBar = app.navigationBars["SampleTaskManagerSwift.MSGTaskListTableView"]
        
        // When
        // Change the first task status to `Done`
        firstCreatedNewTask.tap()
        app.scrollViews.otherElements.buttons["Done"].tap()
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        
        // Change the second task status to `Canceled`
        secondCreatedNewTask.tap()
        app.scrollViews.otherElements.buttons["Canceled"].tap()
        app.navigationBars["SampleTaskManagerSwift.MSGCreateAndEditView"].buttons["Apply"].tap()
        
        // When a task is created, the 'Status:' is `New` by default
        // No need to change the third task status to `New`
        
        // Then
        // Sort by Status
        appNavigationBar.buttons["Sort"].tap()
        appNavigationBar.segmentedControls.buttons["Status"].tap()
        
        let cells = app.tables.cells
        
        // After sorting, verify that the tasks are ordered by `Status`
        let firstFoundCell = cells.elementBoundByIndex(0)
        let firstFoundStatusLabel = firstFoundCell.staticTexts["Status:"].label
        guard let firstTaskStatus = taskStatusFromString("Status: ", taskStatusString: firstFoundStatusLabel) else { XCTFail(); return }
        
        let secondFoundCell = cells.elementBoundByIndex(1)
        let secondFoundStatusLabel = secondFoundCell.staticTexts["Status:"].label
        guard let secondTaskStatus = taskStatusFromString("Status: ", taskStatusString: secondFoundStatusLabel) else { XCTFail(); return }
        
        let thirdFoundCell = cells.elementBoundByIndex(2)
        let thirdFoundStatusLabel = thirdFoundCell.staticTexts["Status:"].label
        guard let thirdTaskStatus = taskStatusFromString("Status: ", taskStatusString: thirdFoundStatusLabel) else { XCTFail(); return }
        
        XCTAssertTrue(firstTaskStatus <= secondTaskStatus)
        XCTAssertTrue(secondTaskStatus <= thirdTaskStatus)
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
