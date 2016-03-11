//
//  MSGTaskListTableViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/9/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import UIKit

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

class MSGTaskListTableViewController: UITableViewController {

    // MARK: - Constants
    private static let taskCellIdentifier = "MSGTaskCell"
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
        
// TODO: // Swipe to Delete
        
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
        taskCell.taskStatusLabel.text = "Status : \(appTask.status.stringRepresentation())"
        
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
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case MSGTaskListTableViewController.updateTaskSegueIdentifier:
                if let taskToEdit = sender as? MSGTask {
                    let appTaskDetailsViewController = segue.destinationViewController as! MSGCreateAndEditViewController
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
        appTaskList.taskListOrder = TaskOrder(rawValue: sender.selectedSegmentIndex)!
        sortOrderSegmentedControl.hidden = true
        appTaskList.sortTaskList()
        tableView.reloadData()
    }
}
