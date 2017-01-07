//
//  GamesTableViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 9/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/**
 *  Just a container for the game data to show.
 */
struct LookupGame {
    var timestamp:NSDate!
    var title:String!
    
    init(aTitle:String, interval:Double) {
        title = aTitle
        timestamp = NSDate(timeIntervalSince1970: interval / timestampFactor)
    }
}

class GamesTableViewController: UITableViewController {
    
    @IBOutlet var menuButton: UIBarButtonItem!
    
    var allGames:[LookupGame] = []
    var selectedIndex:Int = 0
    
    // TODO: Optimise the downloading by only downloading what is necessary and going further as required
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Boilerplate code for the sliding view controller
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = kRevealAmount
        }
        
        
        self.navigationItem.title = "Loading..."
        
        // Download list of all games in the games lookup dictionary in Firebase
        let lookupQuery = GlobalVariables.sharedVariables.dbManager.rootRef.childByAppendingPath("playData/\(GlobalVariables.sharedVariables.uid)/gamesLookup").queryOrderedByChild("timestamp")
        lookupQuery.observeSingleEventOfType(.Value, withBlock: {
            dataSnapshot in
            if dataSnapshot.value is NSNull {
                print("Failed to fetch games lookup")
            } else {
                
                // Convert the downloaded data into an Array of LookupGames, then sort them chronologically
                // You know, its times like this, that I really love Swift... especially its functional functions
                self.allGames = Array((dataSnapshot.value as! [String:[String:String]]).values).map {LookupGame(aTitle: $0["gameType"]!, interval: $0["timestamp"]!.toDouble()!)}.sort { $0.timestamp > $1.timestamp }
                
                // Update the UI on the main Thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    self.navigationItem.title = "Games"
                })
            }
        })
        
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
        return allGames.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GameCell", forIndexPath: indexPath) as! GamesTableViewCell
        
        // Configure the cell...
        cell.bigLabel.text = allGames[indexPath.row].title
        let date = allGames[indexPath.row].timestamp
        let timeSection = date.toString(format: "hh:mm")
        let dateSection = date.toString(format: "eeee dd MMMM yyyy")
        cell.smallLabel.text = timeSection + " of " + dateSection
        
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
        let destination = segue.destinationViewController as! GamesQuickStats
        destination.timestamp = allGames[selectedIndex].timestamp.timeIntervalSince1970
        destination.gameType = GameType.FromTitle(aTitle: allGames[selectedIndex].title!)
    }
    
}
