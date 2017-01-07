//
//  GamesQuickStats.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 9/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/**
 A bit of a data reading quirk fix
 Required because of a Firebase quirk where if an achievement is achieved
 every turn of a game, it will become an array, if not, the data will become a dictionary,
 which is the prefered way to get it back
 
 - parameter ach: The raw data read out of the game data dictionary
 
 - returns: A dictionary with the turn as a string as a key and the achievement as the value
 */
func fixAchievementsToDict(ach:AnyObject) -> [String:String] {
    var achievements:[String:String] = [:]
    if ach is [AnyObject] {
        // Fix the array to become a dictionary
        // Maybe change this later to .toDict, might work
        var newOne:[String:String] = [:]
        let newAch = (ach as! [AnyObject]).filter { $0 != nil }.filter {$0 is String}
        for i in 0..<newAch.count {
            newOne[i.toString] = (newAch as! [String])[i]
        }
        achievements = newOne
    } else {
        achievements = (ach as! [String:String])
    }
    return achievements
    
}

class GamesQuickStats: UIViewController {
    var timestamp:Double = 0
    var gameType:GameType = GameType.Free(rounds: 0)
    private var dataDict:[String:AnyObject] = [:]
    
    @IBOutlet var gameStartLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    
    @IBOutlet var criteriaStackView: UIStackView!
    @IBOutlet var openCriteriaLabel: UILabel!
    @IBOutlet var closeCriteriaLabel: UILabel!
    
    @IBOutlet var mchLabel: UILabel!
    @IBOutlet var mcsLabel: UILabel!
    @IBOutlet var lchLabel: UILabel!
    @IBOutlet var lcsLabel: UILabel!
    
    @IBOutlet var achievementsStackView: UIStackView!
    @IBOutlet var achievementsTable: UITableView!
    @IBOutlet var achDataSource: AchievementsTableViewDataSource!
    
    @IBOutlet var opponentsLabel: UILabel!
    @IBOutlet var opponentsTable: OpponentsTableView!
    
    /**
     Figure out and remove any unnecessary views from the screen according to the type of game
     */
    func removeAnyUnnecessaryViews() {
        switch gameType.gameType.gameClass! {
        case .Cricket:
            criteriaStackView.removeFromSuperview()
            break
        case .Free:
            criteriaStackView.removeFromSuperview()
            break
        case .World:
            criteriaStackView.removeFromSuperview()
            achievementsStackView.removeFromSuperview()
            break
        default:
            break
        }
    }
    
    /**
     Read the achievement data from the game data dictionary, pass it through to a function to have it 'fixed'
     Then pass it onto the tableview data source to present it to the user.
     */
    func doAchievements() {
        let achievements:[String:String] = fixAchievementsToDict(self.dataDict["achievements"]!)
        
        achDataSource.setAchievementsDict(achievements)
        achievementsTable.reloadData()
    }
    
    /**
     Read the user's hit analytics from the analytics dictionary passed in
     Format it, if required
     Present it to the user.
     
     - parameter analytics: The analytics dictionary in the root of the saved game dictionary
     */
    func doAnalytics(analytics:[String:AnyObject]) {
        // This doesn't get used
        // let distribution = analytics["distribution"] as! DBReadGameAnalyticsDistribution
        
        // For the *** common hits, convert everything to DartHits, then get the last one and read its medium length string representation
        let mch = (analytics["mch"] as! DBReadGameTurn).map {DartHit(hitSection: UInt($0["section"]!), hitMultiplier: UInt($0["multiplier"]!))}.last!.mediumString
        let lch = (analytics["lch"] as! DBReadGameTurn).map {DartHit(hitSection: UInt($0["section"]!), hitMultiplier: UInt($0["multiplier"]!))}.last!.mediumString
        let mcs = (analytics["mcs"] as! [Int]).last!.toString
        let lcs = (analytics["lcs"] as! [Int]).last!.toString
        
        // Show the stats to the user.
        mchLabel.text = mch
        mcsLabel.text = mcs
        lchLabel.text = lch
        lcsLabel.text = lcs
    }
    
    /**
     Reads and show the user the open and close criteria to a Countdown game
     */
    func doConditions() {
        let conditions:[String:[String]] = self.dataDict["conditions"] as! [String:[String]]
        openCriteriaLabel.text = conditions["open"]!.first!
        closeCriteriaLabel.text = conditions["close"]!.first!
    }
    
    /**
     Downloads all of the selected game's data, then calls the relevant functions to show it to the user
     */
    func downloadGameData() {
        let uid = GlobalVariables.sharedVariables.uid
        
        GlobalVariables.sharedVariables.dbManager.getDataWithPath("playData/\(uid)/games/\(Int(timestamp * timestampFactor))") {
            data in
            
            // This is mostly updating UI so do it on the main thread
            dispatch_async(dispatch_get_main_queue(), {
                if data is NSNull {
                    print("Failed to fetch game \(self.timestamp * timestampFactor)'s data")
                } else {
                    // Unwrap the data and make it usable
                    self.dataDict = data as! [String:AnyObject]
                    GlobalVariables.sharedVariables.currentGameDataDict = self.dataDict // Cache the downloaded data
                    
                    let isCountdown = self.gameType.gameType.gameClass! == .CountDown
                    
                    // For all game types but World, show Achievements
                    if self.gameType.gameType.gameClass! != .World { self.doAchievements() }
                    
                    // Read and Show Analytics
                    let analytics = self.dataDict["analytics"] as! [String:AnyObject]
                    self.doAnalytics(analytics)
                    
                    // Only for Countdown games, show the Open and Close conditions
                    if isCountdown { self.doConditions() }
                    
                    // Figure out whether or not the score should be the number of turns or both; then show it.
                    let score = self.dataDict["score"] as! Int
                    let turns = self.dataDict["turns"] as! [DBReadGameTurn]
                    if isCountdown {
                        self.scoreLabel.text = "Number of turns taken to \(score == 0 ? "finish":"\(score)"): \(turns.count)."
                    } else {
                        self.scoreLabel.text = "Your score was \(score)."
                    }
                    
                    // If there is an opponents dictionary, show it, otherwise, hide the oppoents table
                    if let opponents = self.dataDict["opponents"] {
                        
                        // Figure out how to rank the users in the table according to score
                        var isHigherBetter = false
                        let isNormalCricket = self.gameType.gameType.title! == GameType.Cricket(cutThroat: false).title
                        if isNormalCricket || self.gameType.gameType.gameClass! == .Free {
                            isHigherBetter = true
                        }
                        
                        self.opponentsTable.setOpponentsData(opponents as! [String], timestamp: Int(self.timestamp * timestampFactor), isHigherBetter: isHigherBetter, yourScore: score)
                    } else {
                        self.opponentsLabel.text = "No Opponents"
                        self.opponentsTable.removeFromSuperview()
                    }
                    
                    // Only add the More Details button once the data has loaded
                    let detailButton = UIBarButtonItem(title: "More Detail", style: .Plain, target: self, action: #selector(GamesQuickStats.showMoreDetail))
                    self.navigationItem.rightBarButtonItem = detailButton
                }
            })
        }
    }
    
    /**
     Presents the More Details TableViewController
     */
    func showMoreDetail() {
        if GlobalVariables.sharedVariables.currentGameDataDict != nil {
            self.performSegueWithIdentifier("GameMoreDetail", sender: self)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        removeAnyUnnecessaryViews()
        
        // Show when the game started
        let date = NSDate(timeIntervalSince1970: timestamp)
        let timeSection = date.toString(format: "hh:mm")
        let dateSection = date.toString(format: "eeee dd MMMM yyyy")
        gameStartLabel.text = "Game started: \(timeSection) of \(dateSection)"
        
        downloadGameData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the navigation bar title to the game type string
        self.navigationItem.title = gameType.gameType.gameClass!.rawValue
    }
}
