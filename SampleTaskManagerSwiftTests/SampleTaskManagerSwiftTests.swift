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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddTask() {
        // Given
        let taskTitleForTest = "Michael's Task"
        let nowDate = NSDate()
        let newTask = MSGTask(taskTitle: taskTitleForTest)
        let myTasks = MSGTaskList()
        
        // When
        
        // Then
        XCTAssertEqual(newTask.status, MSGTask.TaskStatus.New)
        XCTAssertEqualWithAccuracy(nowDate.timeIntervalSinceReferenceDate, newTask.statusDate.timeIntervalSinceReferenceDate, accuracy: 0.001);
        XCTAssertEqual(newTask.title, taskTitleForTest)
        
        myTasks.updateTaskList(newTask)
        XCTAssertTrue(myTasks.taskList.contains( {thisTask in thisTask.title == newTask.title} ) )
    }
    
    func testUpdateTask() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testRemoveTask() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    //    func testPerformanceExample() {
    //        // This is an example of a performance test case.
    //        self.measureBlock {
    //            // Put the code you want to measure the time of here.
    //        }
    //    }
    
}
