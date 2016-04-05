//
//  MSGCreateAndEditViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/9/16.
//  Copyright © 2016 Sogeti USA. All rights reserved.
//

import UIKit

/**
 Mechanism to provide the new or updated `taskToEdit` to the calling View Controller
 */
protocol UpdatedTaskReportingDelegate {
    func reportUpdatedTaskToDelegate(updatedTask: MSGTask)
}

/**
 Edit the details of the `taskToEdit` task
 */
class MSGCreateAndEditViewController: UIViewController,
                                        UITextFieldDelegate,
                                        UITextViewDelegate,
                                        UIScrollViewDelegate,
                                        UIPopoverPresentationControllerDelegate,
                                        DateReportingDelegate {
    
    // MARK: - Types
    enum TaskTextFieldTags: Int {
        case titleTextFieldTag = 1
        case dueDateTextFieldTag
        case statusTextFieldTag
    }

    // MARK: - Constants
    private static let taskStatusSegmentedControlReset = MSGTask.TaskStatus.New.rawValue
    private static let datePickerSegueIdentifier = "DatePickerSegue"
    private static let defaultTaskStatusPhotoName = "lion_3"
    private static let fakeTaskStatusPhotoName = "lion_2"

    // MARK: - Stored Properties
    var taskToEdit: MSGTask?
    
    private weak var activeField: AnyObject?
    private static let defaultTaskStatusPhoto = UIImage(named: MSGCreateAndEditViewController.defaultTaskStatusPhotoName)!
    private static let fakeTaskStatusPhoto = UIImage(named: MSGCreateAndEditViewController.fakeTaskStatusPhotoName)!
    
    private var localDueDate: NSDate?
    private var localStatusDate: NSDate?
    private var localStatusPhoto = MSGCreateAndEditViewController.defaultTaskStatusPhoto
    
    var delegate:  UpdatedTaskReportingDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var taskDueDateTextField: UITextField!
    @IBOutlet weak var taskStatusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var taskStatusDateTextField: UITextField!
    @IBOutlet weak var tastkStatusPhoto: UIImageView!
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        registerForKeyboardNotifications()
        
        taskTitleTextField.enabled = (taskToEdit == nil) // Editing the title of an existing task is diallowed
        
        if let _ = taskToEdit?.statusPhoto {
            localStatusPhoto = UIImage(data: taskToEdit!.statusPhoto!)!
        }
        
        // Populate the Create/Edit View Controller
        updateUI(taskToEdit)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        deregisterFromKeyboardNotifications()
    }
    
    // MARK: - Target / Action Methods
    @IBAction func clearButtonSelected(sender: UIBarButtonItem) {
        
        localStatusPhoto = MSGCreateAndEditViewController.defaultTaskStatusPhoto;
        updateUI(nil)
    }
    
    @IBAction func applyButtonSelected(sender: AnyObject) {
        validateMSGTask()
    }
    
    @IBAction func statusTypeSegmentedControlSelected() {
        localStatusDate = NSDate()
        taskStatusDateTextField.text = stringForTaskDate(localStatusDate)
    }
    
    @IBAction func takePhoto(sender: UIButton) {
        // TODO: Delete this method and button in Storyboard
        localStatusPhoto = MSGCreateAndEditViewController.fakeTaskStatusPhoto
        updateUI(taskToEdit)
    }
    
    // MARK: - Scroll View Delegate
    // Dismiss the Keyboard at the appropriate time
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    // MARK: - Text Field Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        switch textField.tag {
        case TaskTextFieldTags.dueDateTextFieldTag.rawValue:
            performSegueWithIdentifier(MSGCreateAndEditViewController.datePickerSegueIdentifier, sender: textField.tag)
            return false
        case TaskTextFieldTags.statusTextFieldTag.rawValue:
            return false
        default: return true
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    // MARK: - Text View Delegate Method
    func textViewDidBeginEditing(textView: UITextView) {
        activeField = textView
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        activeField = nil
    }
    
    // MARK: - Keyboard Notification 
    // From Apple Documentation - https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
    // and from SO post (for Swift) - http://stackoverflow.com/questions/28813339/move-a-view-up-only-when-the-keyboard-covers-an-input-field
    
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MSGCreateAndEditViewController.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MSGCreateAndEditViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Note to Self: in the Storybord, for this ViewController, had to uncheck 'Extend Edges / Under Top Bar
    // in order for the scrollView and AutoLayout to play nice 
    // See Also: SO Post - http://stackoverflow.com/questions/23508957/working-with-top-layout-guide-in-uiscrollview-through-auto-layout
    func keyboardDidShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect = view.frame
        aRect.size.height -= keyboardSize!.height
        
        if let _ = activeField {
            if (!CGRectContainsPoint(aRect, activeField!.frame.origin)) {
                
                let wasScrollEnabled = scrollView.scrollEnabled
                scrollView.scrollEnabled = true

                scrollView.scrollRectToVisible(activeField!.frame, animated: true)
                
                scrollView.scrollEnabled = wasScrollEnabled
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        
        let contentInsets = UIEdgeInsetsZero
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueIdentifier = segue.identifier {
            switch segueIdentifier {
            case MSGCreateAndEditViewController.datePickerSegueIdentifier:
                let datePickerVC = segue.destinationViewController as! MSGDatePickerViewController
                datePickerVC.dateType = sender as! Int?
                datePickerVC.delegate = self
                if let pickerPopoverPresentationViewController = datePickerVC.popoverPresentationController {
                    pickerPopoverPresentationViewController.delegate = self
                }
            default: break
            }
        }
    }
    
    // MARK: - Popover Presentation Controller Delegate Method
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // MARK: - DateReportingDelegate Method
    func reportSelectedDate(selectedDate: NSDate, dateType: Int?) {
        
        if let _ = dateType {
            if let thisTextFieldTag = TaskTextFieldTags(rawValue: dateType!) {
                switch thisTextFieldTag {
                case .dueDateTextFieldTag:
                    localDueDate = selectedDate
                    taskDueDateTextField.text = stringForTaskDate(localDueDate)
                default: break
                }
            }
        }
    }
    
    // MARK: - Private Utility Methods
    private func updateUI(thisTask: MSGTask?) {
        
        taskTitleTextField.text = taskToEdit?.title // Use taskToEdit not thisTask, Maintains the title from an existing task
        taskDescriptionTextView.text = thisTask?.taskDescription
        
        localDueDate = thisTask?.dueDate
        taskDueDateTextField.text = stringForTaskDate(localDueDate)
        
        taskStatusSegmentedControl.selectedSegmentIndex = thisTask?.status.rawValue ?? MSGCreateAndEditViewController.taskStatusSegmentedControlReset
        
        localStatusDate = thisTask?.statusDate ?? NSDate()
        taskStatusDateTextField.text = stringForTaskDate(localStatusDate)
        
//        tastkStatusPhoto.image = photoImageForTask()
        tastkStatusPhoto.image = localStatusPhoto
    }
    
//    private func photoImageForTask() -> UIImage {
//
//        if let _ = localStatusPhoto {
//        } else {
//            if let _ = taskToEdit?.statusPhoto {
//                localStatusPhoto = UIImage(data: taskToEdit!.statusPhoto!)
//            } else {
//                // The default image is in the bundle, to it is ok to unwrap
//                localStatusPhoto = defaultTaskStatusPhoto
//            }
//        }
//        
//        return localStatusPhoto!
//    }
    
    private func stringForTaskDate(taskDate: NSDate?) -> String? {
        return (taskDate != nil) ? NSDateFormatter.localizedStringFromDate(taskDate!, dateStyle: .ShortStyle, timeStyle: .ShortStyle) : nil
    }
    
    private func validateMSGTask() {
        validateTaskTitle()
    }
    
    private func validateTaskTitle() {
        if let thisTaskTitle = taskTitleTextField.text {
            if thisTaskTitle.isEmpty {
                displayTaskTitleNilAlert()
            } else { // Title is not empty
                validateNewTaskDates()
            }
        } else { // taskTitleTextField is nil, not likely to happen, but this is an Optional
            // Apple documentation: "This string is @"" by default."
            displayTaskTitleNilAlert()
        }
    }
    
    private func validateNewTaskDates() {
        if taskStatusSegmentedControl.selectedSegmentIndex == MSGTask.TaskStatus.New.rawValue {
            if let _ = localDueDate {
                if ((localStatusDate!.compare(localDueDate!) == .OrderedSame) ||
                    (localStatusDate!.compare(localDueDate!) == .OrderedAscending)) {
                    reportUpdatedTask()
                } else {
                    displayTaskDateOrderAlert()
                }
            } else { // Due date is not set
                reportUpdatedTask()
            }
        } else { // This is not a New task
            reportUpdatedTask()
        }
    }
    
    private func reportUpdatedTask() {
        
        let updatedTask = MSGTask(newTaskTitle: taskTitleTextField.text!, // Previously validated that taskTitle is not nil/empty
                                    newTaskTaskDescription: taskDescriptionTextView.text,
                                    newTaskDueDate: localDueDate,
                                    newTaskStatusInt: taskStatusSegmentedControl.selectedSegmentIndex,
                                    newTaskStatusDate: localStatusDate!,
                                    newTaskStatusPhoto: !(MSGCreateAndEditViewController.defaultTaskStatusPhoto.isEqual(localStatusPhoto)) ? UIImagePNGRepresentation(localStatusPhoto) : nil
        )
        
        delegate?.reportUpdatedTaskToDelegate(updatedTask)
        navigationController?.popViewControllerAnimated(true)
    }
    
    private func displayTaskTitleNilAlert() {
        let titleNilAlert = UIAlertController(title: "Title Not Set", message: "Return wihout saving task?", preferredStyle: UIAlertControllerStyle.Alert)
        titleNilAlert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil))
        titleNilAlert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Destructive, handler: { action in
            self.navigationController?.popViewControllerAnimated(true) } ))
        
        presentViewController(titleNilAlert, animated: true, completion: nil)
    }
    
    private func displayTaskDateOrderAlert() {
        let taskDateOrderAlert = UIAlertController(title: "Invalid Due Date", message: "For New tasks, Due Date must be empty or later than Status Date", preferredStyle: UIAlertControllerStyle.Alert)
        taskDateOrderAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        
        presentViewController(taskDateOrderAlert, animated: true, completion: nil)
    }
}
