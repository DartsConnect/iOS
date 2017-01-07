//
//  AchievementsTableView.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 9/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class AchievementsTableViewDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var compressedAchievements:[String:Int] = ["Loading":0] // Just while the table is loading.
    
    /**
     Reads all of the achievements and compresses them,
     This is done by summing the number of times a certain achievemenet is achieved
     and showing that, rather than every single achievement
     i.e. Ton 80: 2 times
     
     - parameter achievements: Dictionary of Achievements, where the key is the turn and the value is the achievement string.
     */
    func setAchievementsDict(achievements:[String:String]) {
        compressedAchievements = [:]
        for (_, ach) in achievements {
            let keys = Array(compressedAchievements.keys)
            if keys.contains(ach) {
                compressedAchievements[ach] = compressedAchievements[ach]! + 1
            } else {
                compressedAchievements[ach] = 1
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return compressedAchievements.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("QuickAchievementCell", forIndexPath: indexPath) as! QuickAchievementsCell
        
        // Configure the cell...
        let key = Array(compressedAchievements.keys)[indexPath.row]
        cell.achName.text = key
        cell.setNumberOfTimes(compressedAchievements[key]!)
        
        return cell
    }
}
