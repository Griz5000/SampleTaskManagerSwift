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
    
    // MSGTaskList Keys -  NSUserDefaults Keys
    private let taskListUserDefaultsKey = "com.Grysikiewicz.Michael.SampleTaskManagerSwift.TaskList"
    private let taskListOrderUserDefaultsKey = "TaskListOrder"
    
    // MSGTask - Dictionary Keys
    private let taskTitleDictionaryKey = "Title"
    private let taskDescriptionDictionaryKey = "Description"
    private let taskDueDateDictionaryKey = "DueDate"
    private let taskStatusDictionaryKey = "Status"
    private let taskStatusDateDictionaryKey = "StatusDate"

    // MARK: - Swift singleton pattern
    private init() {}
    static let sharedInstance = MSGTaskListStore()
    
    // MARK: - Public API
    func storeTaskList(taskListToStore: MSGTaskList) {

        var taskListArrayOfDictionaries = [[:]] // Empty Array of Dictionaries
        
        // Convert taskList to Array of Dictionaries
        for thisTask in taskListToStore.taskList {
            let taskDictionary = [taskTitleDictionaryKey : thisTask.title,
                                  taskDescriptionDictionaryKey : thisTask.description!, // TODO: Unwrapping this is not correct
                                  taskDueDateDictionaryKey : thisTask.dueDate!, // TODO: Unwrapping this is not correct
                                  taskStatusDictionaryKey : thisTask.status.rawValue,
                                  taskStatusDateDictionaryKey : thisTask.statusDate]
            
            taskListArrayOfDictionaries.append(taskDictionary)
        }
        
        // Save taskListArrayOfDictionaries and taskListOrder to NSUserDefaults
        NSUserDefaults.standardUserDefaults().setObject(taskListArrayOfDictionaries, forKey: taskListUserDefaultsKey)
        NSUserDefaults.standardUserDefaults().setObject(taskListToStore.taskListOrder.rawValue, forKey: taskListOrderUserDefaultsKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func retrieveTaskList() -> MSGTaskList? {
// TODO:
        var restoredTaskList: MSGTaskList?
        
        let taskListArrayOfDictionaries = NSUserDefaults.standardUserDefaults().objectForKey(taskListUserDefaultsKey)

        // Pull taskListOrder from NSUserDefaults
        // Pull taskList from NSUserDefault
        // For each item in the Array
        // Convert the Dictionary to a Task
        // Add the Task to the taskList
        
        return restoredTaskList
    }
    
    // MARK: - Private Utility Methods

}