//
//  MSGTaskListTableViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/9/16.
//  Copyright © 2016 Sogeti USA. All rights reserved.
//

import UIKit

/**
 Add the stringRepresentation method to the MSGTask.TaskStatus enum
 */
extension MSGTask.TaskStatus {
    
    func stringRepresentation() -> String {
        switch self {
        case .New:
            return "New"
        case .Done:
            return "Done"
        case .Canceled:
            return "Canceled"
        }
    } 
}

/**
 Top level view controller for the SampleTaskManagerSwift App.  Consists of a TableViewController which displays a list of user defined tasks.  Tasks can be sorted by selecting the `Sort` button.  A new task is created by selecting the `New` button.  An existing task is modified by selecting the task from the list of tasks.
 */
class MSGTaskListTableViewController: UITableViewController, UpdatedTaskReportingDelegate {

    // MARK: - Constants
    private static let taskCellIdentifier = "MSGTaskCell"
    private static let newTaskSegueIdentifier = "NewTaskSegue"
    private static let updateTaskSegueIdentifier = "UpdateTaskSegue"
    private static let taskTableCellHeight: CGFloat = 130.0
    private static let sortSegmentedControlFontSize: CGFloat = 12.0
    private static let noSegmentSelected = -1
    
    // MARK: - Stored  Properties
    // Restore the task list from persistant storage, or an empty task list if none was found
    private let appTaskList = MSGTaskList.restoreTaskList()
    
    // MARK: - Outlets
    @IBOutlet weak var sortOrderSegmentedControl: UISegmentedControl!
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the sortOrderSegmentedControl
        sortOrderSegmentedControl.setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Arial", size: MSGTaskListTableViewController.sortSegmentedControlFontSize)!], forState: .Normal)
        sortOrderSegmentedControl.hidden = true
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
        let taskCell: MSGTaskTableViewCell =
            tableView.dequeueReusableCellWithIdentifier(MSGTaskListTableViewController.taskCellIdentifier,
                forIndexPath: indexPath) as! MSGTaskTableViewCell
        
        let appTask = appTaskList.taskList[indexPath.row]
        
        // Configure the cell...
        taskCell.taskTitleLabel.text = "Title: \(appTask.title)"
        
        var taskDueDateString: String
        if let _ = appTask.dueDate {
            taskDueDateString = NSDateFormatter.localizedStringFromDate(appTask.dueDate!, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        } else {
            taskDueDateString = "Unset"
        }
        taskCell.taskDueDateLabel.text = "Due Date: \(taskDueDateString)"
        taskCell.taskStatusLabel.text = "Status: \(appTask.status.stringRepresentation())"
        
        let taskStatusDateString = NSDateFormatter.localizedStringFromDate(appTask.statusDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
        taskCell.taskStatusDateLabel.text = "Status Date: \(taskStatusDateString)"
        
        return taskCell
    }
    
    // MARK: - Table View Delegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MSGTaskListTableViewController.taskTableCellHeight
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedTask = appTaskList.taskList[indexPath.row]
        performSegueWithIdentifier(MSGTaskListTableViewController.updateTaskSegueIdentifier, sender: selectedTask)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        // Intentionally left empty - SO post -- http://stackoverflow.com/questions/24103069/swift-add-swipe-to-delete-tableviewcell
//    }
    
    // Add the Swipe-to-Delete functionality
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete") {action in
            // Handle delete
            self.appTaskList.removeTaskFromList(self.appTaskList.taskList[indexPath.row])
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
//        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") {action in
//            //handle edit
//        }
        
        return [deleteAction/*, editAction */]
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case MSGTaskListTableViewController.updateTaskSegueIdentifier,
                 MSGTaskListTableViewController.newTaskSegueIdentifier:
                
                let appTaskDetailsViewController = segue.destinationViewController as! MSGCreateAndEditViewController
                appTaskDetailsViewController.delegate = self
                
                if let taskToEdit = sender as? MSGTask {
                    appTaskDetailsViewController.taskToEdit = taskToEdit
                }
                
            default: break
            }
        }
    }
    
    // MARK: - Target / Action
    @IBAction func sortBarButtonItemSelected(sender: UIBarButtonItem) {
        sortOrderSegmentedControl.selectedSegmentIndex = MSGTaskListTableViewController.noSegmentSelected
        sortOrderSegmentedControl.hidden = false
    }
    
    @IBAction func sortSegmentedControlSelected(sender: UISegmentedControl) {
        appTaskList.taskListOrder = MSGTaskList.TaskOrder(rawValue: sender.selectedSegmentIndex)! // Automatically sorts the list
        sortOrderSegmentedControl.hidden = true
        tableView.reloadData()
    }
    
    // MARK: - UpdatedTaskReportingDelegate Method
    func reportUpdatedTaskToDelegate(updatedTask: MSGTask) {
        appTaskList.updateTaskList(updatedTask)
        tableView.reloadData()
    }
}
