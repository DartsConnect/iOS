//
//  AchievementsCategoryTableViewCell.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 10/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// Exposes the UI elements to the code
class AchievementsCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet var category: UILabel!
    @IBOutlet private var numTimes: UILabel!
    
    /**
     Some text formatting before being displayed
     
     - parameter t: The number of times the achievement was achieved.
     */
    func setNumberOfTimes(t:Int) {
        numTimes.text = "\(t) time\(t > 1 ? "s":"")"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
