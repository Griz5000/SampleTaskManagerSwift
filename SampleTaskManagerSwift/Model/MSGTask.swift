//
//  MSGTask.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/7/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import Foundation

/**
 `MSGTask` stores information about a single task.
 
 In order to implement persistance to a file, this class must inherit from NSObject so that it can implement the NSCoding protocol
 */
class MSGTask: NSObject, NSCoding {
    
    // MARK: - Types
    enum TaskStatus: Int {
        case New
        case Done
        case Canceled
    }
    
    struct MSGTaskPropertyKey {
        static let titleKey = "title"
        static let taskdescriptionKey = "taskDescription"
        static let dueDateKey = "dueDate"
        static let statusIntKey = "status"
        static let statusDateKey = "statusDate"
    }
    
    // MARK: - Stored Properties
    let title: String           // The `title` defines the MSGTask and should never change
    var taskDescription: String?
    var dueDate: NSDate?
    var status: TaskStatus
    var statusDate: NSDate
    
    // MARK: - Initializers
    init(taskTitle: String) {
        title = taskTitle
        status = .New
        statusDate = NSDate()
        
        super.init()
    }
    
    convenience init(newTaskTitle: String,
                     newTaskTaskDescription: String?,
                     newTaskDueDate: NSDate?,
                     newTaskStatusInt: Int,
                     newTaskStatusDate: NSDate) {
            
            self.init(taskTitle: newTaskTitle)
            
            self.taskDescription = newTaskTaskDescription
            self.dueDate = newTaskDueDate
            self.status = TaskStatus(rawValue: newTaskStatusInt) ?? .New
            self.statusDate = newTaskStatusDate
    }
    
    // MARK: - NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(title, forKey: MSGTaskPropertyKey.titleKey)
        aCoder.encodeObject(taskDescription, forKey: MSGTaskPropertyKey.taskdescriptionKey)
        aCoder.encodeObject(dueDate, forKey: MSGTaskPropertyKey.dueDateKey)
        aCoder.encodeInteger(status.rawValue, forKey: MSGTaskPropertyKey.statusIntKey)
        aCoder.encodeObject(statusDate, forKey: MSGTaskPropertyKey.statusDateKey)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let archivedTitle = aDecoder.decodeObjectForKey(MSGTaskPropertyKey.titleKey) as! String
        let archivedTaskDescription = aDecoder.decodeObjectForKey(MSGTaskPropertyKey.taskdescriptionKey) as? String
        let archivedDueDate = aDecoder.decodeObjectForKey(MSGTaskPropertyKey.dueDateKey) as? NSDate
        let archivedStatusInt = aDecoder.decodeIntegerForKey(MSGTaskPropertyKey.statusIntKey)
        let archivedStatusDate = aDecoder.decodeObjectForKey(MSGTaskPropertyKey.statusDateKey) as! NSDate
        
        self.init(newTaskTitle: archivedTitle,
                  newTaskTaskDescription: archivedTaskDescription,
                  newTaskDueDate: archivedDueDate,
                  newTaskStatusInt: archivedStatusInt,
                  newTaskStatusDate: archivedStatusDate)
    }
    
    }

// MARK: Operator Override
func ==(left:MSGTask, right: MSGTask) -> Bool {
    return left.title == right.title
}
