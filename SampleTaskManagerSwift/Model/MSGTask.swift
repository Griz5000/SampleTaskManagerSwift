//
//  MSGTask.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/7/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import Foundation


class MSGTask {
    
    enum TaskStatus: Int {
        case New
        case Done
        case Canceled
    }
    
    // MARK: - Stored Properties
    let title: String
    var description: String?
    var dueDate: NSDate?
    var status: TaskStatus
    var statusDate: NSDate
    
    // MARK: - Initializers
    init(taskTitle: String) {
        title = taskTitle
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
    
    // MARK: - Public API
    func taskValid() -> Bool {
        return dateSequenceValid()
    }
    
    // MARK: - Private Utility Methods
    private func dueDateValid() -> Bool {
        return (dueDate != nil)
    }
    
    private func dateSequenceValid() -> Bool {
        return dueDateValid() &&
//            ((statusDate.compare(dueDate!) == .OrderedSame) ||
//                (statusDate.compare(dueDate!) == .OrderedAscending))
            statusDate.compare(dueDate!) == .OrderedAscending
    }
}

// MARK: Operator Override
func ==(left:MSGTask, right: MSGTask) -> Bool {
    return left.title == right.title
}
