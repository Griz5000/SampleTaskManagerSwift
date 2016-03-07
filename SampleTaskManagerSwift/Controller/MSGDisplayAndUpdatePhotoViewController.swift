//
//  MSGDisplayAndUpdatePhotoViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 4/6/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import UIKit

/**
 Display the camera UI for replacing the photo
 */
protocol UpdateTaskStatusPhotoDelegate {
    func taskStatusPhotoCamerSelected()
}

/** 
 Display and edit the status photo
 */
class MSGDisplayAndUpdatePhotoViewController: UIViewController {

    // MARK: - Stored Properties
    var photoToUpdate: UIImage? {
        didSet {
            updateDisplay()
        }
    }
    
    var delegate: UpdateTaskStatusPhotoDelegate?

    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        updateDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func previewActionItems() -> [UIPreviewActionItem] {
        
        let cameraAction = UIPreviewAction(title: "Replace Photo", style: .Default) { (action: UIPreviewAction, viewController: UIViewController) -> Void in
            
            print("Camera Action")
            self.delegate?.taskStatusPhotoCamerSelected()
        }
        
        return [cameraAction]
    }
    
    // MARK: - Target / Action Methods
    @IBAction func cameraSelected(sender: AnyObject) {
        delegate?.taskStatusPhotoCamerSelected()
    }
    
    // MARK: - Private Utility Methods
    private func updateDisplay() {
        photoImageView?.image = photoToUpdate
    }
}
