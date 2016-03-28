//
//  MSGTaskTableViewCell.swift
//  SampleTaskManagerSwift
//
//  Created by Michael Grysikiewicz on 3/9/16.
//  Copyright © 2016 Sogeti USA. All rights reserved.
//

import UIKit

class MSGTaskTableViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var taskDueDateLabel: UILabel!
    @IBOutlet weak var taskStatusLabel: UILabel!
    @IBOutlet weak var taskStatusDateLabel: UILabel!
    
    // MARK: - Delegate Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
