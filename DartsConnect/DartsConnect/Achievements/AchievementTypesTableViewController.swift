//
//  AchievementTypesTableViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 10/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class AchievementTypesTableViewController: UITableViewController {
    
    @IBOutlet var menuButton:UIBarButtonItem!
    
    var achievedCategories:[String:Int] = [:]
    var selectedIndex:Int = 0
    
    /**
     Download all of the user's achievements,
     and format the data to be shown in the table view.
     
     - author: Jordan Lewis
     - date: Tuesday 10 July 2016
     - todo: N/A
     */
    func downloadAchievements() {
        let uid = GlobalVariables.sharedVariables.uid
        GlobalVariables.sharedVariables.dbManager.getDataWithPath("playData/\(uid)/achievements") {
            data in
            if data is NSNull {
                print("Failed to fetch achievements")
            } else {
                let achievements = data as! [String:[String:AnyObject]]
                let keys = Array(achievements.keys)
                // Create the dataset for this table view. ["Achievement Fullname":number of times]
                for key in keys {
                    self.achievedCategories[Achievement(shortName:key)!.fullName] = (achievements[key]!["numTimes"]! as! Int)
                }
                
                // Update the UI on the main Thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationItem.title = "Achievements"
                    self.tableView.reloadData()
                })
                
                // Cache the achievement data in the Global Variables for faster access later.
                var temp:[String:[String:[String:[String]]]] = [:]
                for (key, value) in achievements { // Weed out the numTimes
                    let games = value["games"] as! [String:[String]]
                    temp[key] = ["games":games]
                }
                GlobalVariables.sharedVariables.achievements = temp
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Boilerplate code for the sliding view controller
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = kRevealAmount
        }
        
        // Make navigation bar title "Loading..." to tell the user what is happening. The downloadAchievements function will fix this when done.
        self.navigationItem.title = "Loading..."
        downloadAchievements()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return achievedCategories.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AchievementsCategoryCell", forIndexPath: indexPath) as! AchievementsCategoryTableViewCell
        
        // Configure the cell...
        let keys = Array(achievedCategories.keys)
        cell.category.text = keys[indexPath.row]
        cell.setNumberOfTimes(achievedCategories[keys[indexPath.row]]!)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectedIndex = indexPath.row
        return indexPath
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destinationViewController as! AchievementGamesTableViewController
        destination.achievementCategory = Achievement(longName: Array(achievedCategories.keys)[selectedIndex])!
    }
}
