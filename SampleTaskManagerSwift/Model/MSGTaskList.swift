//
//  MSGTaskList.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/7/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import Foundation

/**
 Model for the SampleTaskManagerSwift application
 */
class MSGTaskList {
    
    enum TaskOrder {
        case Title
        case DueDate
        case Status
        case StatusDate
    }
    
    // MARK: - Stored Properties
    var taskList: [MSGTask]
    var taskListOrder: TaskOrder
    
    // MARK: - Initializers
    // TODO: TaskList ought to be a singleton
    init() {
        (taskList, taskListOrder) = MSGTaskList.restoreTaskList()
    }
    
    // MARK: - Public API
    /**
    Replace the `withTask` in the `taskList`
    
    - Parameter withTask: Task data supplied by the UI
    */
    func updateTaskList(withTask: MSGTask) {
        if !taskList.filter( {$0 == withTask} ).isEmpty {
            removeTask(withTask)
        }
        
        addTask(withTask)
        
        saveTaskList()
    }
    
    /**
     Remove `taskToRemove from the `taskList` if it is contained in the `taskList`
     
     - Parameter taskToRemove: Task data supplied by the UI
     */
    func removeTaskFromList(taskToRemove: MSGTask) {
        removeTask(taskToRemove)
        
        saveTaskList()
    }

    // MARK: - Private Utility Methods
    private func saveTaskList() {
        // TODO:
        if !taskList.isEmpty {
            MSGTaskList.sortTaskList()
            
            // Convert taskList to Array of Dictionaries
            // Save taskListOrder to NSUserDefaults
            // Save taskList to NSUserDefaults
        }
    }
    
    private class func restoreTaskList() -> ([MSGTask], TaskOrder) {
        // TODO:
        let restoredTaskList = [MSGTask]()
        let restoredTaskOrder: TaskOrder = .Title
        
        // Pull taskListOrder from NSUserDefaults
        // Pull taskList from NSUserDefaults
        // For each item in the Array
        // Convert the Dictionary to a Task
        // Add the Task to the taskList
        
        MSGTaskList.sortTaskList()
        
        return (restoredTaskList, restoredTaskOrder)
    }
    
    private class func sortTaskList() {
        // TODO:
    }
    
    private func addTask(taskToAdd: MSGTask) {
        if !taskList.contains( {thisTask in thisTask.title == taskToAdd.title} ) {
            taskList.append(taskToAdd)
        }
    }
    
    private func removeTask(taskToRemove: MSGTask) {
        if let indexForTask = taskList.indexOf( {thisTask in thisTask.title == taskToRemove.title} ) {
            taskList.removeAtIndex(indexForTask)
        }
    }
}