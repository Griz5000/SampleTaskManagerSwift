//
//  MSGTask.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/7/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import Foundation


class MSGTask {
    
    enum TaskStatus {
        case New
        case Done
        case Canceled
    }
    
    // MARK: - Stored Properties
    var title: String?
    var description: String?
    var dueDate: NSDate?
    var status: TaskStatus?
    var statusDate: NSDate?
    
    // MARK: - Initializers
    init() {
        status = .New
        statusDate = NSDate()
    }
    
    init(title: String,
        description:String,
        dueDate: NSDate,
        status:TaskStatus,
        statusDate:NSDate) {
            self.title = title
            self.description = description
            self.dueDate = dueDate
            self.status = status
            self.statusDate = statusDate
    }
    
    // MARK: - Class Validation Methods
    func taskValid() -> Bool {
        return (titleValid() && dateSequenceValid())
    }
    
    func titleValid() -> Bool {
        return (title != nil)
    }
    
    func dueDateValid() -> Bool {
        return (dueDate != nil)
    }
    
    func statusDateValid() -> Bool {
        return (statusDate != nil)
    }
    
    func dateSequenceValid() -> Bool {
        return dueDateValid() &&
            statusDateValid() &&
            statusDate?.compare(dueDate!) == .OrderedAscending
    }
    
}

// MARK: Operator Override
func ==(left:MSGTask, right: MSGTask) -> Bool {
    return left.title == right.title
}
