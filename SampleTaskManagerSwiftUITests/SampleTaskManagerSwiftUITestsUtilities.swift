//
//  SampleTaskManagerSwiftUITestsUtilities.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 4/1/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import XCTest

class SampleTaskManagerSwiftUITestsUtilities {
    
    // MARK: - Class Constants
    static let offsetForTomorrow: NSTimeInterval = 86400.0 // In seconds
    static let offsetForDayAfterTomorrow: NSTimeInterval = 2 * SampleTaskManagerSwiftUITestsUtilities.offsetForTomorrow // In seconds
    static let aShortWhile: UInt32 = 5 // In seconds
    
    // NOTE: Due to not being allowed to access App data structures in UI Testing, the values for the TaskStatus enum are simulated
    static let MSGTask_TaskStatus_New: Int      = 0
    static let MSGTask_TaskStatus_Done: Int     = 1
    static let MSGTask_TaskStatus_Canceled: Int = 2
    
    // MARK: - Utility Methods
    // Ensure that enough time has elapsed so that auto-generated timestamps are not identical
    class func sleepUntilNextMinute() {
        let startMinutes = NSCalendar.currentCalendar().components([.Minute], fromDate: NSDate()).minute
        var incrementedMinutes: Int
        repeat {
            sleep(SampleTaskManagerSwiftUITestsUtilities.aShortWhile)
            incrementedMinutes = NSCalendar.currentCalendar().components([.Minute], fromDate: NSDate()).minute
        } while startMinutes == incrementedMinutes
    }
    
    class func cropLabelString(taskPrefixString: String, taskLabelString: String) -> String {
        var croppedTaskLabelString = taskLabelString
        
        if let rangeOfPrefix = taskLabelString.rangeOfString(taskPrefixString) {
            let indexFollowingPrefix = rangeOfPrefix.endIndex
            croppedTaskLabelString = croppedTaskLabelString.substringFromIndex(indexFollowingPrefix)
        }
        
        return croppedTaskLabelString
    }
    
    class func taskDateFromString(taskPrefixString: String, taskDateString: String) -> NSDate? {
        // Crop task prefix from the string
        let croppedTaskDateString = cropLabelString(taskPrefixString, taskLabelString: taskDateString)
        
        let taskDateFormatter = NSDateFormatter()
        taskDateFormatter.dateStyle = .ShortStyle //Match the style that was used to create the date string
        taskDateFormatter.timeStyle = .ShortStyle
        return taskDateFormatter.dateFromString(croppedTaskDateString)
    }
    
    class func removeAllTasksFromTaskList() {
        // Find the last element in the tableView
        let cells = XCUIApplication().tables.cells
        
        while cells.count > 0 {
            cells.elementBoundByIndex(0).swipeLeft()
            XCUIApplication().tables.buttons["Delete"].tap()
        }
    }
    
    // I could not use MSGTask.TaskStatus directly in the UI Testing, per link below
    class func taskStatusFromString(taskPrefixString: String, taskStatusString: String) -> Int? {
        
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
            return SampleTaskManagerSwiftUITestsUtilities.MSGTask_TaskStatus_New
        case "Done":
            return SampleTaskManagerSwiftUITestsUtilities.MSGTask_TaskStatus_Done
        case "Canceled":
            return SampleTaskManagerSwiftUITestsUtilities.MSGTask_TaskStatus_Canceled
        default:
            return nil
        }
    }
}
