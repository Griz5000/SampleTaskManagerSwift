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
    var taskList = [MSGTask]()
    var taskListOrder: TaskOrder = .Title
    
    // MARK: - Initializers
    init() {
        restoreTaskList()
    }
    
    // MARK: - Public API
    /**
     Retrieve the `taskList` from persistant storage
     */
    func restoreTaskList() {
        if let retrievedTaskList = MSGTaskListStore.sharedInstance.retrieveTaskList() {
            taskList = retrievedTaskList.taskList
            taskListOrder = retrievedTaskList.taskListOrder
        }
    }
    
    /**
    Replace the `withTask` in the `taskList`
    
    - Parameter withTask: Task data supplied by the UI
    */
    func updateTaskList(withTask: MSGTask) {
        if !taskList.filter( {$0 == withTask} ).isEmpty {
            removeTask(withTask)
        }
        
        addTask(withTask)
        sortTaskList()
        
        MSGTaskListStore.sharedInstance.storeTaskList(self)
    }
    
    /**
     Remove `taskToRemove from the `taskList` if it is contained in the `taskList`
     
     - Parameter taskToRemove: Task data supplied by the UI
     */
    func removeTaskFromList(taskToRemove: MSGTask) {
        
        removeTask(taskToRemove)
        sortTaskList()
        
        MSGTaskListStore.sharedInstance.storeTaskList(self)
    }

    // MARK: - Private Utility Methods
    private func sortTaskList() {

        switch taskListOrder {
        case .Title:
            taskList.sortInPlace( {$0.title < $1.title} )
        case .DueDate:
            taskList.sortInPlace( { (left, right) -> Bool in
                let leftDueDate = left.dueDate ?? NSDate.distantPast()
                let rightDueDate = right.dueDate ?? NSDate.distantPast()
                return leftDueDate.compare(rightDueDate) == .OrderedAscending } )
        case .Status:
            taskList.sortInPlace( {$0.status.rawValue < $1.status.rawValue} )
        case .StatusDate:
            taskList.sortInPlace( {$0.statusDate.compare($1.statusDate) == .OrderedAscending} )
        }
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