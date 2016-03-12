//
//  MSGCreateAndEditViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/9/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import UIKit

// MARK: - Types
enum TaskTextFieldTags: Int {
    case titleTextFieldTag = 1
    case dueDateTextFieldTag
    case statusTextFieldTag
}

class MSGCreateAndEditViewController: UIViewController,
                                        UITextFieldDelegate,
                                        UITextViewDelegate,
                                        UIScrollViewDelegate,
                                        UIPopoverPresentationControllerDelegate,
                                        DateReportingDelegate {
    
    // MARK: - Constants
    private static let taskStatusSegmentedControlReset = 0
    private static let datePickerSegueIdentifier = "DatePickerSegue"

    // MARK: - Stored Properties
    var taskToEdit: MSGTask?
    weak var activeField: AnyObject?
    
    private var localDueDate: NSDate?
    private var localStatusDate: NSDate?
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var taskTitleTextField: UITextField!
    @IBOutlet weak var taskDescriptionTextView: UITextView!
    @IBOutlet weak var taskDueDateTextField: UITextField!
    @IBOutlet weak var taskStatusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var taskStatusDateTextField: UITextField!
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        registerForKeyboardNotifications()
        
        taskTitleTextField.enabled = (taskToEdit == nil) // Editing the title of an existing task is diallowed
 
        // Populate the Create/Edit View Controller
        populateUI()
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
        
        taskTitleTextField.text = taskToEdit?.title // Maintains the title from an existing Task
        taskDescriptionTextView.text = nil
        
        localDueDate = nil
        taskDueDateTextField.text = stringForTaskDate(localDueDate)
        
        taskStatusSegmentedControl.selectedSegmentIndex = MSGCreateAndEditViewController.taskStatusSegmentedControlReset
        
        localStatusDate = NSDate()
        taskStatusDateTextField.text = stringForTaskDate(localStatusDate)
    }
    
    @IBAction func applyButtonSelected(sender: AnyObject) {
// TODO: // Verify valid MSGTask
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Scroll View Delegate
    // Dismiss the Keyboard at the appropriate time
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
    @IBAction func statusTypeSegmentedControlSelected() {
        taskStatusDateTextField.text = stringForTaskDate(NSDate())
    }
    
    // MARK: - Text Field Delegate Methods
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
// TODO: // Display DatePicker for DueDate
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
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
    
    // MARK: - DateReportingDelegate Method
    func reportSelectedDate(selectedDate: NSDate, dateType: Int) {
        print("Date: \(stringForTaskDate(selectedDate)!)")
        print("DateType: \(dateType)")
    }
    
    // MARK: - Private Utility Methods
    private func populateUI() {

        taskTitleTextField.text = taskToEdit?.title
        taskDescriptionTextView.text = taskToEdit?.taskDescription
        
        localDueDate = taskToEdit?.dueDate
        taskDueDateTextField.text =  stringForTaskDate(localDueDate)
        
        taskStatusSegmentedControl.selectedSegmentIndex = taskToEdit?.status.rawValue ?? MSGCreateAndEditViewController.taskStatusSegmentedControlReset

        localStatusDate = taskToEdit?.statusDate ?? NSDate()
        taskStatusDateTextField.text = stringForTaskDate(localStatusDate)
    }
    
    private func stringForTaskDate(taskDate: NSDate?) -> String? {
        return (taskDate != nil) ? NSDateFormatter.localizedStringFromDate(taskDate!, dateStyle: .ShortStyle, timeStyle: .ShortStyle) : nil
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}
