//
//  SampleTaskManagerSwiftTests.swift
//  SampleTaskManagerSwiftTests
//
//  Created by Michael Grysikiewicz on 3/7/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import XCTest
@testable import SampleTaskManagerSwift

class SampleTaskManagerSwiftTests: XCTestCase {

    let taskTitleForTest = "Michael's Task"
    let secondTaskTitleForTest = "John's Task"
    let thirdTaskTitleForTest = "Jacob's Task"
    let taskTitleForBadStatus = "Rocky Mountain High"
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCreateTask() {
        
        // Given
        let nowDate = NSDate()
        
        // When
        let newTask = MSGTask(taskTitle: taskTitleForTest)
        
        // Then
        XCTAssertEqual(newTask.title, taskTitleForTest)
        XCTAssertEqual(newTask.status, MSGTask.TaskStatus.New)
        XCTAssertEqualWithAccuracy(nowDate.timeIntervalSinceReferenceDate, newTask.statusDate.timeIntervalSinceReferenceDate, accuracy: 0.001);
    }
    
    func testAddTaskToList() {
        // Given
        let newTask = MSGTask(taskTitle: taskTitleForTest)
        
        // When
        let myTaskList = MSGTaskList.restoreTaskList()
        
        // Then
        myTaskList.updateTaskList(newTask)
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.title == newTask.title} ) )
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.status == newTask.status} ) )
    }
    
    func testReplaceTaskInList() {
        // Given
        let newTask = MSGTask(taskTitle: taskTitleForTest)
        let myTaskList = MSGTaskList.restoreTaskList()
        
        // When
        newTask.status = .Done
        myTaskList.updateTaskList(newTask)
        
        // Then
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.status == newTask.status} ) )
    }
    
    func testAddSecondTaskToList() {
        // Given
        let newTask = MSGTask(taskTitle: secondTaskTitleForTest)
        
        // When
        let myTaskList = MSGTaskList.restoreTaskList()
        
        // Then
        myTaskList.updateTaskList(newTask)
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.title == newTask.title} ) )
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.status == newTask.status} ) )
    }
    
    func testAddThirdTaskToList() {
        // Given
        let newTask = MSGTask(taskTitle: thirdTaskTitleForTest)
        
        // When
        let myTaskList = MSGTaskList.restoreTaskList()
        
        // Then
        newTask.status = .Canceled
        myTaskList.updateTaskList(newTask)
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.title == newTask.title} ) )
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.status == newTask.status} ) )
    }
    
    func testRemoveSecondTaskFromList() {
        // Given
        let newTask = MSGTask(taskTitle: secondTaskTitleForTest)
        
        // When
        let myTaskList = MSGTaskList.restoreTaskList()
        
        // Then
        myTaskList.removeTaskFromList(newTask)
        XCTAssertFalse(myTaskList.taskList.contains( {thisTask in thisTask.title == newTask.title} ) )
    }
    
    func testCreateBadStatusTask() {
        
        // Given
        let nowDate = NSDate()
        let badStatus: Int = 13
        
        // When
        let newTask = MSGTask(newTaskTitle: taskTitleForBadStatus, newTaskTaskDescription: nil, newTaskDueDate: nil, newTaskStatusInt: badStatus, newTaskStatusDate: nowDate)
        
        // Then
        XCTAssertEqual(newTask.title, taskTitleForBadStatus)
        XCTAssertEqual(newTask.status, MSGTask.TaskStatus.New)
    }
    
    func testAddTaskToListWithBadTaskOrder() {
        // Given
        let nowDate = NSDate()
        let badStatus: Int = 13
        let newTask = MSGTask(newTaskTitle: taskTitleForBadStatus, newTaskTaskDescription: nil, newTaskDueDate: nil, newTaskStatusInt: badStatus, newTaskStatusDate: nowDate)
        let badTaskOrder: Int = 42
        
        // When
        let myTaskList = MSGTaskList(newTaskList: [newTask], newTaskOrderInt: badTaskOrder)
        
        // Then
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.title == newTask.title} ) )
        XCTAssertTrue(myTaskList.taskList.contains( {thisTask in thisTask.status == newTask.status} ) )
        XCTAssertEqual(myTaskList.taskListOrder, MSGTaskList.TaskOrder.Title)
    }
    
    func testSortByTitleTaskOrder() {
        // Given
        let myTaskList = MSGTaskList()
        
        var newTask = MSGTask(taskTitle: taskTitleForTest)
        myTaskList.updateTaskList(newTask)
        
        newTask = MSGTask(taskTitle: secondTaskTitleForTest)
        myTaskList.updateTaskList(newTask)
        
        // When
        myTaskList.taskListOrder = .Title // Sorts in .taskListOrder 'didSet'
        
        // Then
        XCTAssertTrue(myTaskList.taskList.count == 2)
        
        let title1 = myTaskList.taskList[0].title
        let title2 = myTaskList.taskList[1].title
        
        XCTAssertTrue(title1 <= title2)
    }
    
    func testSortByDueDateTaskOrder() {
        // Given
        let myTaskList = MSGTaskList()
        
        let distantPast = NSDate.distantPast()
        let distantFuture = NSDate.distantFuture()
        
        var newTask = MSGTask(taskTitle: taskTitleForTest)
        newTask.dueDate = distantPast
        myTaskList.updateTaskList(newTask)
        
        newTask = MSGTask(taskTitle: secondTaskTitleForTest)
        newTask.dueDate = distantFuture
        myTaskList.updateTaskList(newTask)
        
        // When
        myTaskList.taskListOrder = .DueDate // Sorts in .taskListOrder 'didSet'
        
        // Then
        XCTAssertTrue(myTaskList.taskList.count == 2)
        
        let dueDate1 = myTaskList.taskList[0].dueDate
        let dueDate2 = myTaskList.taskList[1].dueDate
        
        XCTAssertTrue(dueDate1!.compare(dueDate2!) == .OrderedAscending)
    }
    
    func testSortByNilDueDateTaskOrder() {
        // Given
        let myTaskList = MSGTaskList()
        
        var newTask = MSGTask(taskTitle: taskTitleForTest)
        // Not setting .dueDate results in a nil .dueDate
        // Sort uses distantPast for nil .dueDate
        myTaskList.updateTaskList(newTask)
        
        newTask = MSGTask(taskTitle: secondTaskTitleForTest)
        // Not setting .dueDate results in a nil .dueDate
        // Sort uses distantPast for nil .dueDate
        myTaskList.updateTaskList(newTask)
        
        // When
        myTaskList.taskListOrder = .DueDate // Sorts in .taskListOrder 'didSet'
        
        // Then
        XCTAssertTrue(myTaskList.taskList.count == 2)
        
        let dueDate1 = myTaskList.taskList[0].dueDate ?? NSDate.distantPast()
        let dueDate2 = myTaskList.taskList[1].dueDate ?? NSDate.distantPast()
        
        XCTAssertTrue((dueDate1.compare(dueDate2) == .OrderedAscending) ||
                      (dueDate1.compare(dueDate2) == .OrderedSame))
    }
    
    func testSortByStatusTaskOrder() {
        // Given
        let myTaskList = MSGTaskList()
        
        var newTask = MSGTask(taskTitle: taskTitleForTest)
        newTask.status = .Canceled
        myTaskList.updateTaskList(newTask)
        
        newTask = MSGTask(taskTitle: secondTaskTitleForTest)
        newTask.status = .Done
        myTaskList.updateTaskList(newTask)
        
        newTask = MSGTask(taskTitle: thirdTaskTitleForTest)
        newTask.status = .New
        myTaskList.updateTaskList(newTask)
        
        // When
        myTaskList.taskListOrder = .Status // Sorts in .taskListOrder 'didSet'
        
        // Then
        XCTAssertTrue(myTaskList.taskList.count == 3)
        
        XCTAssertTrue(myTaskList.taskList[0].status.rawValue < myTaskList.taskList[1].status.rawValue)
        XCTAssertTrue(myTaskList.taskList[1].status.rawValue < myTaskList.taskList[2].status.rawValue)
    }
    
    func testSortByStatusDateTaskOrder() {
        // Given
        let myTaskList = MSGTaskList()
        
        let distantPast = NSDate.distantPast()
        let distantFuture = NSDate.distantFuture()
        
        var newTask = MSGTask(taskTitle: taskTitleForTest)
        newTask.statusDate = distantPast
        myTaskList.updateTaskList(newTask)
        
        newTask = MSGTask(taskTitle: secondTaskTitleForTest)
        newTask.statusDate = distantFuture
        myTaskList.updateTaskList(newTask)
        
        // When
        myTaskList.taskListOrder = .StatusDate // Sorts in .taskListOrder 'didSet'
        
        // Then
        XCTAssertTrue(myTaskList.taskList.count == 2)
        
        let statusDate1 = myTaskList.taskList[0].statusDate
        let statusDate2 = myTaskList.taskList[1].statusDate
        
        XCTAssertTrue(statusDate1.compare(statusDate2) == .OrderedAscending)
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measureBlock {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
