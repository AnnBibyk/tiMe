//
//  TimeTableViewCell.swift
//  tiMe
//
//  Created by Anna Bibyk on 16.02.2020.
//  Copyright © 2020 Anna Bibyk. All rights reserved.
//

import UIKit

class TimeTableViewCell: UITableViewCell {

    @IBOutlet weak var timeNoteLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var expanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
