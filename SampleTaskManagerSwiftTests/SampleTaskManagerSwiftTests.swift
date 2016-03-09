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
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measureBlock {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
