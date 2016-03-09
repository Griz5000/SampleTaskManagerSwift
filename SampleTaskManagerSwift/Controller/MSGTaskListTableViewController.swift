//
//  MSGTaskListTableViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/9/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import UIKit

class MSGTaskListTableViewController: UITableViewController {

    private static let taskCellIdentifier = "MSGTaskCell"
    private static let updateTaskSegueIdentifier = "UpdateTaskSegue"
    
    // Restore the task list from persistant storage, or an empty task list if none was found
    private let appTaskList = MSGTaskList.restoreTaskList()
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appTaskList.taskList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: MSGTaskTableViewCell =
            tableView.dequeueReusableCellWithIdentifier(MSGTaskListTableViewController.taskCellIdentifier,
                forIndexPath: indexPath) as! MSGTaskTableViewCell
// TODO:
        // Configure the cell...

        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedTask = appTaskList.taskList[indexPath.row]
        performSegueWithIdentifier(MSGTaskListTableViewController.updateTaskSegueIdentifier, sender: selectedTask)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            if let taskToEdit = sender as? MSGTask {
                switch segueIdentifier {
                case MSGTaskListTableViewController.updateTaskSegueIdentifier:
                    let appTaskDetailsViewController = segue.destinationViewController as! MSGCreateAndEditViewController
                        appTaskDetailsViewController.taskToEdit = taskToEdit
                default: break
                }
            }
        }
    }
}
