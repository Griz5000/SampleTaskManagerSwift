//
//  MSGDatePickerViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/11/16.
//  Copyright © 2016 Sogeti USA. All rights reserved.
//

import UIKit

/**
 Mechanism to report the selected date to the calling View Controller
 */
protocol DateReportingDelegate {
    func reportSelectedDate(selectedDate: NSDate, dateType: Int?)
}

/**
 Display a DatePicker.  This one happens to be in a PopoverPresentationController, based on the presenting segue.  This View Controller is resized using the `preferredContentSize` method.
 */
class MSGDatePickerViewController: UIViewController {

    // MARK: - Stored  Properties
    var dateType: Int?
    
    var delegate: DateReportingDelegate?
    
    // MARK: - Outlets
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Initialize the date in the UIDatePicker
        taskDatePicker.date = NSDate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Retun the selected date and dateType (i.e. Due Date or Status Date, just return input value)
        delegate?.reportSelectedDate(taskDatePicker.date, dateType: dateType)
        
        super.viewWillDisappear(animated)
    }
    
    override  var preferredContentSize: CGSize {
        get {                           // presentingViewController - whichever view controller is presenting you
                                        // checking for != nil assures that the bounds are set
            if taskDatePicker != nil && presentingViewController != nil {
                return taskDatePicker.sizeThatFits(presentingViewController!.view.bounds.size)
            } else {
                return super.preferredContentSize
            }
        }
        set { super.preferredContentSize = newValue }
    }
}
