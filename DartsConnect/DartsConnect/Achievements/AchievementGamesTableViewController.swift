//
//  AchievementGamesTableViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 11/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class AchievementGamesTableViewController: UITableViewController {
    
    var achievementCategory:Achievement = Achievement(shortName: "lTon")! // Just give this variable a temporary value for now, it will be overridden later. Just to avoid optionals.
    var dataset:[Double:[AnyObject]] = [:]
    var selectedIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = achievementCategory.fullName
        
        let games = GlobalVariables.sharedVariables.achievements![achievementCategory.shortName]!["games"]!
        
        let uid = GlobalVariables.sharedVariables.uid
        
        for (key, turns) in games {
            // download game type
            GlobalVariables.sharedVariables.dbManager.getDataWithPath("playData/\(uid)/gamesLookup/\(key)/gameType") {
                data in
                if data is NSNull {
                    print("Failed to fetch game type")
                } else {
                    self.dataset[key.toDouble()!] = [data as! String, turns.count]
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        self.tableView.reloadData()
                    })
                }
            }
        }
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
        return dataset.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AchievementGameCell", forIndexPath: indexPath) as! AchievementGamesTableViewCell
        
        // Configure the cell...
        let keys = Array(dataset.keys).sort {$1 > $0}
        let key = keys[indexPath.row]
        cell.gametype.text = (dataset[key]![0] as! String)
        cell.setTimestampDate(key / timestampFactor)
        cell.setNumberOfTimes(dataset[key]![1] as! Int)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
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
        
        let destination = segue.destinationViewController as! GameDetailDataTableViewController
        destination.heading = "Turns" // this is just to suite the conditionals as I am reusing that code
        // The code below this will download the required data, so while it is doing that, show "Loading..."
        destination.navigationItem.title = "Loading..."
        
        let uid = GlobalVariables.sharedVariables.uid
        let timestamp = Array(dataset.keys)[selectedIndex]
        // Convert all the turns for the selected achievement into Integers in the array from Strings
        let achTurns = GlobalVariables.sharedVariables.achievements!["\(achievementCategory.shortName)"]!["games"]![timestamp.toInt.toString]!.map { $0.toInt()! }
        
        // Download the turns for the game that was selected for the achievement
        GlobalVariables.sharedVariables.dbManager.getDataWithPath("playData/\(uid)/games/\(timestamp.toInt)/turns") {
            data in
            if data is NSNull {
                print("Failed to fetch turns for achievements")
            } else {
                
                // For every turn that the user got this achievement, get the throws, and convert those values into shortened strings for display
                for turnIndex in achTurns {
                    // Some complex type conversion... trust me, this works :)
                    let throwNames = DartTurn(arrThrows:
                        (data as! [[[String:Int]]])[turnIndex].map {
                            DartHit(hitSection: UInt($0["section"]!), hitMultiplier: UInt($0["multiplier"]!))
                        }).shortNames
                    destination.dataset[turnIndex.toString] = throwNames
                }
                
                // Update the UI in the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    destination.navigationItem.title = self.achievementCategory.fullName
                    destination.tableView.reloadData()
                })
            }
        }
        
    }
    
}
