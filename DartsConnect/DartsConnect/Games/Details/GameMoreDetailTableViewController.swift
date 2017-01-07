//
//  GameMoreDetailTableViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 10/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class GameMoreDetailTableViewController: UITableViewController {
    
    // Read from the cache
    var dataDict:[String:AnyObject] = GlobalVariables.sharedVariables.currentGameDataDict!
    var tableData:[String] = [ // The available more data
        "Achievements",
        "Distribution",
        "Turns"
    ]
    var selectedIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "More Detail"
        if dataDict["achievements"] == nil {
            tableData.removeAtIndex(0)
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
        return tableData.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: nil)
        
        // Configure the cell...
        cell.textLabel?.text = tableData[indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        self.performSegueWithIdentifier("ToMoreDetailsTable", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destinationViewController as! GameDetailDataTableViewController
        
        let heading = tableData[selectedIndex]
        destination.heading = heading
        
        if heading == "Turns" || heading == "Achievements" {
            let raw:[DBReadGameTurn] = dataDict["turns"] as! [DBReadGameTurn]
            
            // Converts an array of turns into an dictionary with keys of turn number and value of array of hit short names
            destination.dataset = raw.map {
                DartTurn(arrThrows:
                    $0.map{
                        DartHit(hitSection: UInt($0["section"]!), hitMultiplier: UInt($0["multiplier"]!)
                        )
                    }
                )
                }.map { $0.shortNames }.toDict
            
            /*
             If the user wants to see the achievements,
             take the turns array that was assigned above,
             then add the achievement string to end of that array for each turn.
             This will automatically be recognised and shown to the user.
             */
            if heading == "Achievements" {
                let achRaw = fixAchievementsToDict(dataDict["achievements"]!)
                let refDataset = destination.dataset
                destination.dataset.removeAll()
                for (indexStr, ach) in achRaw {
                    destination.dataset[indexStr] = refDataset[indexStr]! + [ach] // Append the achievement to the end of the turns array
                }
            }
        }
        
        /*
         If user wants to see the game's throw distribution,
         Read it and get it fixed for further reading,
         Convert the dictionary's values to have the prefixes S, D, T for single, double, or triple multiplier hits
         Assign it to the destination view controller's datasource.
         */
        if heading == "Distribution" {
            let raw:DistributionDict = DistributionFixer().fixKeysToRead(dataDict["analytics"]!["distribution"] as! DistributionDict)
            let multiplierConverter = ["S", "D", "T"]
            destination.dataset = raw.mapValues {
                Array($1.mapValues{
                    "\(multiplierConverter[$0.toInt()! - 1]): \($1)"
                    }.values)
            }
        }
    }
}
