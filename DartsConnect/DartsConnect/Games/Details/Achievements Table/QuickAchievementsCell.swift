//
//  QuickAchievementsCell.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 9/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// Exposes the UI elements to the code
class QuickAchievementsCell: UITableViewCell {
    
    @IBOutlet var achName: UILabel!
    @IBOutlet var numTimes: UILabel!
    
    /**
     Some text formatting before being displayed
     
     - parameter times: The number of times the achievement was achieved.
     */
    func setNumberOfTimes(times:Int) {
        numTimes.text = "\(times) time\(times > 1 ? "s":"")"
    }
}
