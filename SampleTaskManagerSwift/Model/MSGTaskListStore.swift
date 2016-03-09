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
    
    // MARK: - Constants
    private static let taskListDirectoryComponent = "TaskListArchive"
    
    // MARK: - Archiving Paths
    static let documentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let archiveURL = documentsDirectory.URLByAppendingPathComponent(taskListDirectoryComponent)

    // MARK: - Swift singleton pattern
    private init() {}
    
    static let sharedInstance = MSGTaskListStore()
    
    // MARK: - Public API
    func storeTaskList(taskListToStore: MSGTaskList) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(taskListToStore,
            toFile: MSGTaskListStore.archiveURL.path!)
        
        print("Archiving tasks was \(isSuccessfulSave ? "True" : "False")")

    }
    
    func retrieveTaskList() -> MSGTaskList? {
        
        return NSKeyedUnarchiver.unarchiveObjectWithFile(MSGTaskListStore.archiveURL.path!) as? MSGTaskList
    }
}