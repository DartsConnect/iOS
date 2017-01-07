//
//  GameDetailDataTableViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 10/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

class GameDetailDataTableViewController: UITableViewController {
    
    var heading:String = ""
    var dataset:[String:[String]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigation bar title
        self.navigationItem.title = heading
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
        let cell = tableView.dequeueReusableCellWithIdentifier("MoreDetailCell", forIndexPath: indexPath) as! MoreDetailsTableViewCell
        
        // Configure the cell...
        let keys = Array(dataset.keys).map {$0.toInt()!}.sort().map {$0.toString}
        let key = keys[indexPath.row]
        // Some string formatting and then assign it
        cell.title.text = "\(heading == "Distribution" ? "":"Turn") \(heading == "Turns" ? (key.toInt()! + 1):key.toInt()!):"
        
        if heading != "Achievements" {
            cell.achievement.text = ""
        } else {
            cell.achievement.text = dataset[key]![3]
        }
        
        // Index 1 and 0 are swapped because the data was sorted alphabetically and D is before S only for distribution
        // If you're looking at this, this is probably the ugliest part of my program, please check else where
        if key == "25" {
            cell.throw1.text = ""
            if heading == "Distribution" {
                cell.throw2.text = dataset[key]![1]
                cell.throw3.text = dataset[key]![0]
            } else {
                cell.throw2.text = dataset[key]![0]
                cell.throw3.text = dataset[key]![1]
            }
        } else {
            if heading == "Distribution" {
                cell.throw1.text = dataset[key]![1]
                cell.throw2.text = dataset[key]![0]
            } else {
                cell.throw1.text = dataset[key]![0]
                cell.throw2.text = dataset[key]![1]
            }
            if dataset[key]!.count == 3 {
                cell.throw3.text = dataset[key]![2]
            }
        }
        
        return cell
    }
    
}
