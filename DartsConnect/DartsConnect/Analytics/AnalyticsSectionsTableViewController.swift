//
//  AnalyticsSectionsTableViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 11/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class AnalyticsSectionsTableViewController: UITableViewController {
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    var sectionHeadings:[String] = []
    var selectedIndex:Int = 0
    var distributionTableData:[String:[String]] = [:]
    var cricketString:String = ""
    
    /**
     Downloads the all of the user's Analytics
     and keeps them in memory for faster access.
     
     - author: Jordan Lewis
     - date: Tuesday 25 July 2016
     - todo: N/A
     */
    func downloadAnalytics() {
        let uid = GlobalVariables.sharedVariables.uid
        GlobalVariables.sharedVariables.dbManager.getDataWithPath("playData/\(uid)/analytics") {
            data in
            if data is NSNull {
                print("Failed to fetch analytics")
            } else {
                // Set the downloaded data to the right data type
                let analytics = data as! [String:DistributionDict]
                
                self.sectionHeadings.append("Lifetime Distribution")
                if analytics.count == 0 { self.sectionHeadings.removeAll() } // If in the rare case that someone logs in, but hasn't actually played a game yet.
                if analytics.count == 2 { self.sectionHeadings.append("Cricket") } // Add Cricket to the table if it is in the downloaded analytics data
                
                // Update the UI
                dispatch_async(dispatch_get_main_queue(), {
                    self.navigationItem.title = "Analytics"
                    self.tableView.reloadData()
                })
                
                // Set the distribution table data, so it is ready for when the user wants to see it
                let rawDistributionDict:DistributionDict = DistributionFixer().fixKeysToRead(analytics["lifetime distribution"]!)
                self.distributionTableData = self.fixDistributionForTable(rawDistributionDict)
                
                // Create a string for the Cricket analytics, to show in the main table
                if analytics.count == 2 {
                    let cricket:DistributionDict = analytics["cricket"]!
                    let keys:[String] = Array(cricket.keys)
                    
                    if keys.contains("normal") { self.cricketString += "Total scored on self: \(cricket["normal"]!["scored"]!)." }
                    if keys.contains("cut-throat") { self.cricketString += "Cut-Throat, on me: \(cricket["cut-throat"]!["onMe"]!), on others: \(cricket["cut-throat"]!["onOthers"]!)." }
                }
            }
        }
    }
    
    /**
     Converts a nested Dictionary of dart hit values to a single dictionary
     
     - parameter distributionDict: The raw distribution dictionary read directly from Firebase.
     
     - returns: A Dictionary of Keys as Hit Sections, and values an array of how many times the multiplier has been hit. ie ["1":["S: 10", "D: 5", "T: 3"]
     */
    func fixDistributionForTable(distributionDict:DistributionDict) -> [String:[String]] {
        let raw:DistributionDict = DistributionFixer().fixKeysToRead(distributionDict)
        let multiplierConverter = ["S", "D", "T"]
        return raw.mapValues {
            Array($1.mapValues{
                "\(multiplierConverter[$0.toInt()! - 1]): \($1)"
                }.values)
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
        
        // Make navigation bar title "Loading..." to tell the user what is happening. The downloadAnalytics function will fix this when done.
        self.navigationItem.title = "Loading..."
        downloadAnalytics()
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
        return sectionHeadings.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        
        // Configure the cell...
        cell.textLabel?.text = sectionHeadings[indexPath.row]
        cell.accessoryType = .DisclosureIndicator
        
        if sectionHeadings[indexPath.row] == "Cricket" {
            cell.detailTextLabel?.text = cricketString
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        
        // Using multiway selection here provides overhead for later if other analytics sections are added.
        switch sectionHeadings[selectedIndex] {
        case "Lifetime Distribution":
            self.performSegueWithIdentifier("ShowLifetimeDistribution", sender: self)
            break
        default:
            break
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if sectionHeadings[selectedIndex] == "Lifetime Distribution" {
            let destination = segue.destinationViewController as! GameDetailDataTableViewController
            destination.heading = "Distribution"
            destination.navigationItem.title = "Loading..."
            destination.dataset = self.distributionTableData
        }
    }
    
}
