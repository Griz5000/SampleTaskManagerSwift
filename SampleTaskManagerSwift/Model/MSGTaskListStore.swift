//
//  MSGTaskListStore.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/7/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import Foundation

/**
 Handle persistance of a TaskList
 */
class MSGTaskListStore {
    
    // Swift singleton pattern
    private init() {}
    static let sharedInstance = MSGTaskListStore()
    
    func storeTaskList(taskList: MSGTaskList) {
// TODO:
        // Convert taskList to Array of Dictionaries
        // Save taskListOrder to NSUserDefaults
        // Save taskList to NSUserDefaults
    }
    
    func retrieveTaskList() -> MSGTaskList? {
// TODO:
        var restoredTaskList: MSGTaskList?

        // Pull taskListOrder from NSUserDefaults
        // Pull taskList from NSUserDefaults
        // For each item in the Array
        // Convert the Dictionary to a Task
        // Add the Task to the taskList
        
        return restoredTaskList
    }
}