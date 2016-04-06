//
//  MSGDisplayAndUpdatePhotoViewController.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 4/6/16.
//  Copyright © 2016 Michael Grysikiewicz. All rights reserved.
//

import UIKit

/** 
 Display the
 */
class MSGDisplayAndUpdatePhotoViewController: UIViewController {

    // MARK: - Stored Properties
    var photoToUpdate: UIImage?

    // MARK: - Outlets
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: - View Controller Delegate Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        photoImageView.image = photoToUpdate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
