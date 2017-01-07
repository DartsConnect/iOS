//
//  AchievementGamesTableViewCell.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 11/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// Exposes the UI elements to the code
class AchievementGamesTableViewCell: UITableViewCell {
    
    @IBOutlet var gametype: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet private var numTimes: UILabel!
    
    /**
     Some text formatting for the timestamp of when the game was played
     
     - parameter interval: An NSTimeInterval from Unix Epoch time.
     */
    func setTimestampDate(interval:NSTimeInterval) {
        let date = NSDate(timeIntervalSince1970: interval)
        let timeSection = date.toString(format: "hh:mm")
        let dateSection = date.toString(format: "eeee dd MMMM yyyy")
        timestamp.text = "\(timeSection) on \(dateSection)"
    }
    
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
