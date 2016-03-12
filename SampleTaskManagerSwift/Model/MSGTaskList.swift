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
class MSGTaskList: NSObject, NSCoding {
    
    // MARK: - Types
    enum TaskOrder: Int {
        case Title
        case DueDate
        case Status
        case StatusDate
    }
    
    struct MSGTaskListPropertyKey {
        static let taskListKey = "TaskList"
        static let taskListOrderKey = "TaskListOrder"
    }
    
    // MARK: - Stored Properties
    var taskList = [MSGTask]()
    var taskListOrder: TaskOrder = .Title
    
    // MARK: - Initializers
    override init() {
        super.init()
    }
    
    convenience init(newTaskList: [MSGTask], newTaskOrderInt: Int) {
        self.init()
        
        taskList = newTaskList
        taskListOrder = TaskOrder(rawValue: newTaskOrderInt) ?? .Title
    }
    
    // MARK: - NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(taskList, forKey: MSGTaskListPropertyKey.taskListKey)
        aCoder.encodeInteger(taskListOrder.rawValue, forKey: MSGTaskListPropertyKey.taskListOrderKey)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let archivedTaskList = aDecoder.decodeObjectForKey(MSGTaskListPropertyKey.taskListKey) as! [MSGTask]
        let archivedTaskOrderInt = aDecoder.decodeIntegerForKey(MSGTaskListPropertyKey.taskListOrderKey)
        
        self.init(newTaskList: archivedTaskList, newTaskOrderInt: archivedTaskOrderInt)
    }
    
    // MARK: - Public API
    /**
     Retrieve the `taskList` from persistant storage
     */
    static func restoreTaskList() -> MSGTaskList {
        return MSGTaskListStore.sharedInstance.retrieveTaskList() ?? MSGTaskList()
    }
    
    /**
     Replace the `withTask` in the `taskList`
     
     - Parameter withTask: Task data supplied by the UI
     */
    func sortTaskList() {
        sortTasksInList()
        
        MSGTaskListStore.sharedInstance.storeTaskList(self)
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
    }
    
    /**
     Remove `taskToRemove from the `taskList` if it is contained in the `taskList`
     
     - Parameter taskToRemove: Task data supplied by the UI
     */
    func removeTaskFromList(taskToRemove: MSGTask) {
        
        removeTask(taskToRemove)
        sortTaskList()
    }

    // MARK: - Private Utility Methods
    private func sortTasksInList() {

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