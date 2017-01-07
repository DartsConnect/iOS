//
//  MainViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 8/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit
import SVProgressHUD
import SWRevealViewController

/// A simple class for those games you see at the bottom of the screen
class RecentGameView: UIView {
    init(_ game:String) {
        super.init(frame: CGRectZero)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let titleLabel = UILabel()
        titleLabel.text = game
        titleLabel.textColor = kColorBlack
        titleLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLabel)
        
        let icon = UIImageView()
        icon.backgroundColor = kColorRed
        self.addSubview(icon)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(titleLabel.bindAttribute(.Bottom, toView: self))
        self.addConstraints(titleLabel.fullHorizontalConstraint)
        self.addConstraint(titleLabel.bindAttribute(.CenterX, toView: self))
        
        self.addConstraint(icon.bindAttribute(.Width, toView: titleLabel))
        self.addConstraint(icon.equateAttribute(.Height, toView: icon, attribute2: .Width))
        self.addConstraint(icon.equateAttribute(.Bottom, toView: titleLabel, attribute2: .Top))
        self.addConstraint(icon.bindAttribute(.CenterX, toView: self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MainViewController: UIViewController {
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var totalDartThrowsLabel: UILabel!
    @IBOutlet var lastPlayedLabel: UILabel!
    @IBOutlet var mchLabel: UILabel!
    @IBOutlet var mcsLabel: UILabel!
    @IBOutlet var lchLabel: UILabel!
    @IBOutlet var lcsLabel: UILabel!
    @IBOutlet var recentGamesStack: UIStackView!
    @IBOutlet var menuButton: UIBarButtonItem!
    
    /**
     Now that the user is logged in, fetch the user's username from the database to show to the user.
     
     - parameter uid: The user's UID.
     - author: Jordan Lewis
     - date: Tuesday 08 July 2016
     - todo: N/A
     */
    func getUsername(uid:String) {
        // Fetch Username
        GlobalVariables.sharedVariables.dbManager.getDataWithPath("users/\(uid)") {
            data in
            if data is NSNull {
                print("Failed to fetch user data")
            } else {
                let dict = data as! [String:String]
                let username = dict["username"]!
                
                // Update the UI on the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.welcomeLabel.text = "Welcome \(username)!"
                })
            }
        }
    }
    
    /**
     Fetches the user's lifetime distribution,
     then calculates the user's:
     Most Common Hit (Section and Multiplier)
     Most Common Section
     Least Common Hit
     Least Common Section
     
     - parameter uid: The user's UID.
     - author: Jordan Lewis
     - date: Tuesday 08 July 2016
     - todo: N/A
     */
    func getDistribution(uid:String) {
        // Download lifetime distribution
        GlobalVariables.sharedVariables.dbManager.getDataWithPath("playData/\(uid)/analytics/lifetime distribution") {
            data in
            if data is NSNull {
                print("Returned NSNull for lifetime distribution")
            } else {
                let distribution = DistributionFixer().fixKeysToRead(data as! DistributionDict)
                
                // BEGIN Find Total Dart Throws
                var total:Int = 0
                for (_, sectionHits) in distribution {
                    total += Array(sectionHits.values).reduce(0, combine: +)
                }
                print("Total Dart Throws: \(total)")
                // END Find Total Dart Throws
                
                // BEGIN Finding most common and least common
                let analyser = DistributionAnalyser(distribution)
                let mch = analyser.mostCommonHit.last!.mediumString
                let mcs = analyser.mostCommonSection.last!.toString
                let lch = analyser.leastCommonHit.last!.mediumString
                let lcs = analyser.leastCommonSection.last!.toString
                // END Finding most common and least common
                
                // Update the UI on the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.totalDartThrowsLabel.text = "Total Dart Throws: \(total)"
                    self.mchLabel.text = mch
                    self.mcsLabel.text = mcs
                    self.lchLabel.text = lch
                    self.lcsLabel.text = lcs
                })
            }
        }
    }
    
    /**
     Runs a NoSQL query to the Firebase server/database
     to return the 5 most recent games, ordered by timestamp
     
     - parameter uid: The user's UID.
     - author: Jordan Lewis
     - date: Tuesday 08 July 2016
     - todo: N/A
     */
    func getRecentGames(uid:String) {
        // Download 5 most recent games
        let gamesLookupRef = GlobalVariables.sharedVariables.dbManager.rootRef.childByAppendingPath("playData/\(uid)/gamesLookup")
        
        // Construct and run the query
        gamesLookupRef.queryOrderedByChild("timestamp").queryLimitedToLast(5).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            if snapshot.value is NSNull {
                print("Recent games query returned NSNull")
            } else {
                let recentGames:[[String:String]] = Array((snapshot.value as! [String:[String:String]]).values) // Convert the data type of the returned data to a usable one
                
                // Get the timestamp of the most recent date and convert it to a string
                let mostRecent = NSDate(timeIntervalSince1970: recentGames.first!["timestamp"]!.toDouble()! / timestampFactor).toString(format: "dd MMMM yyyy (hh:mm)")
                
                // Update the UI on the main thread
                dispatch_async(dispatch_get_main_queue(), {
                    self.lastPlayedLabel.text = "Last Played: \(mostRecent)"
                    
                    let proportion:CGFloat = 0.15 // The constant multiplier for adjusting the sizes of the icons for the games.
                    
                    // Only add filler views if there are two or less recent games.
                    if recentGames.count <= 2 {
                        self.addFillerRecentGame(proportion)
                    }
                    
                    // Add all (up to 5) games to the horizontal stack view
                    for game in recentGames {
                        let gameTitle = game["gameType"]!
                        let recentGameView = RecentGameView(gameTitle)
                        self.recentGamesStack.addArrangedSubview(recentGameView)
                        self.recentGamesStack.addConstraint(recentGameView.relationalAttributeConstraintTo(self.recentGamesStack, attribute: .Width, multiplier: proportion))
                    }
                    
                    if recentGames.count <= 2 {
                        self.addFillerRecentGame(proportion)
                    }
                })
            }
        })
    }
    
    /**
     Adds a transparent UIView to the recentGames stackview
     to centre the 1 or 2 single recent games.
     
     - parameter proportion: A CGFloat of value up to 1.0
     - author: Jordan Lewis
     - date: Tuesday 26 July 2016
     - todo: N/A
     */
    func addFillerRecentGame(proportion:CGFloat) {
        let filler = UIView()
        filler.translatesAutoresizingMaskIntoConstraints = false
        self.recentGamesStack.addArrangedSubview(filler)
        self.recentGamesStack.addConstraint(filler.relationalAttributeConstraintTo(self.recentGamesStack, attribute: .Width, multiplier: proportion))
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
        
        let uid = GlobalVariables.sharedVariables.uid
        
        // Call the functions required to populate the UI
        getUsername(uid)
        getDistribution(uid)
        getRecentGames(uid)
    }
}
