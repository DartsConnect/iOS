//
//  OpponentsTableView.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 9/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class OpponentsTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var dataset:[(String, Int)] = []
    
    func setOpponentsData(opponents:[String], timestamp:Int, isHigherBetter:Bool, yourScore:Int) {
        
        dataset.append(("You", yourScore))
        
        self.dataSource = self
        self.delegate = self
        self.reloadData()
        
        /*
         For every oppoenent, get their username, once that completes, get their score
         Once both have succeeded, add the data to the main table datasource
         Sort it according to whether or not a higher score is better
         Then reload the tableview on the main thread.
         */
        for opponentUID in opponents {
            // Fetch the oppoenent's user name
            GlobalVariables.sharedVariables.dbManager.getDataWithPath("users/\(opponentUID)/username") {
                usernameData in
                if usernameData is NSNull {
                    print("Failed to fetch username for opponents with uid \(opponentUID)")
                } else {
                    let username = usernameData as! String
                    
                    // Fetch the opponent's score
                    GlobalVariables.sharedVariables.dbManager.getDataWithPath("playData/\(opponentUID)/games/\(timestamp)/score") {
                        scoreData in
                        if scoreData is NSNull {
                            print("Failed to fetch score for \(username) in opponents")
                        } else {
                            let score = scoreData as! Int
                            
                            // Add the score and sort it according to whether or not a higher score is better
                            self.dataset.append((username, score))
                            if isHigherBetter {
                                self.dataset.sortInPlace { $0.1 > $1.1 }
                            } else {
                                self.dataset.sortInPlace { $0.1 < $1.1 }
                            }
                            
                            // Updated the table on the main thread
                            dispatch_async(dispatch_get_main_queue(), {
                                self.reloadData()
                            })
                        }
                    }
                }
            }
            
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataset.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("OpponentsCell") as! OpponentsCell
        
        // Configure the cell...
        cell.place.text = "\(indexPath.row + 1)."
        cell.name.text = dataset[indexPath.row].0
        cell.score.text = dataset[indexPath.row].1.toString
        
        return cell
    }
    
}
