//
//  MSGDatePickerViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/11/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import UIKit

class MSGDatePickerViewController: UIViewController {

    // MARK: - Stored  Properties
    var dateType: Int?
    
    // MARK: - Outlets
    @IBOutlet weak var taskDatePicker: UIDatePicker!
    
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override  var preferredContentSize: CGSize {
        get {                           // presentingViewController - which ever view controller is presenting you
                                        // assures that the bounds are set
            if taskDatePicker != nil && presentingViewController != nil {
                return taskDatePicker.sizeThatFits(presentingViewController!.view.bounds.size)
            } else {
                return super.preferredContentSize
            }
        }
        set { super.preferredContentSize = newValue }
    }
}
