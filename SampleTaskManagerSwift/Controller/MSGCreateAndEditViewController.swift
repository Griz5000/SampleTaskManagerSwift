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

class MSGCreateAndEditViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    // MARK: - Constants
    private static let noSegmentSelected = -1
    
    // MARK: - Stored Properties
    var taskToEdit: MSGTask?
    weak var activeField: AnyObject?
    
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
    }
    
    @IBAction func applyButtonSelected(sender: AnyObject) {
// TODO:
        // Verify valid MSGTask
        navigationController?.popViewControllerAnimated(true)
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
// TODO:
        switch textField.tag {
        case TaskTextFieldTags.dueDateTextFieldTag.rawValue,
             TaskTextFieldTags.statusTextFieldTag.rawValue:
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
    
    // MARK: - Private Utility Methods
    private func populateUI() {
// TODO:
        taskTitleTextField.text = taskToEdit?.title
        taskDescriptionTextView.text = taskToEdit?.taskDescription
        taskDueDateTextField.text = (taskToEdit?.dueDate != nil) ?
            NSDateFormatter.localizedStringFromDate(taskToEdit!.dueDate!, dateStyle: .ShortStyle, timeStyle: .ShortStyle) : nil
        taskStatusSegmentedControl.selectedSegmentIndex = taskToEdit?.status.rawValue ?? MSGCreateAndEditViewController.noSegmentSelected
        taskStatusDateTextField.text = (taskToEdit?.statusDate != nil) ?
            NSDateFormatter.localizedStringFromDate(taskToEdit!.statusDate, dateStyle: .ShortStyle, timeStyle: .ShortStyle) : nil
    }
}
