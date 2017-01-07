//
//  DartThrowStructs.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 27/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

/**
 *  A protocol that requires a dictionary that is able to be saved to Firebase to be implemented
 */
protocol Saveable { // Friday 27 May 2016
    var saveDataDict:[String:AnyObject] { get }
}

// MARK: Dart Game Throw Distribution
/**
 *  A wrapper for containing a DartGame's distribution dictionary
 *  This struct handles any analysis required with a distribution dictionary
 *  and also formats the dictionary to be saveable
 */
struct DartGameDistribution:Saveable {
    var game:DartGame!
    var distributionDict:DistributionDict = [:]
    var mostCommonHit:[DartHit]!
    var leastCommonHit:[DartHit]!
    var mostCommonSection:[Int]!
    var leastCommonSection:[Int]!
    
    /// The implementation of Saveable, returns a dictionary containing the distribution and most & least common hits & sections
    var saveDataDict: [String : AnyObject] {
        get {
            return [
                "distribution":DistributionFixer().fixKeysToSave(distributionDict),
                "mch":mostCommonHit.map {$0.saveDataDict}.toDict,
                "lch":leastCommonHit.map {$0.saveDataDict}.toDict,
                "mcs":mostCommonSection.toDict,
                "lcs":leastCommonSection.toDict
            ]
        }
    }
    
    /**
     Generates a distribution dict by reading all of the DartHits and Turns
     This does this by generating a distribution dictionary of 0s then
     adding the actual hits of from the game.
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - parameters:
     - None
     - returns: None
     - todo: None
     */
    private mutating func generateDistributionDict() {
        var gameDistribution:DistributionDict = [:]
        
        // Fill the life time distribution updater dict with zeros
        for hit in 1...21 {
            let adjHit = hit == 21 ? 25 : hit // Turn 21 into 25, otherwise don't touch the number, just because a dartboard doesn't have a 21, rather a 25
            if adjHit == 25 {
                gameDistribution[adjHit.toString] = [
                    "1":0,
                    "2":0
                ]
            } else {
                gameDistribution[adjHit.toString] = [
                    "1":0,
                    "2":0,
                    "3":0,
                ]
            }
        }
        
        // Fill in the distribution dictionary with the hits from the game
        for num in 1...21 { // For every section on the dartboard
            let adjNum = num == 21 ? 25 : num // Turn 21 into 25, otherwise don't touch the number, just because a dartboard doesn't have a 21, rather a 25
            for hit in game.allThrows where hit.section == UInt(adjNum) { // For every throw where the section is the current section
                if adjNum != 25 && hit.multiplier != 3 { // Do it for every number except for 25 with a triple, because it doesn't exist
                    gameDistribution[adjNum.toString]![hit.multiplier.toString]! += 1 // Increment up the hit section and multiplier
                }
            }
        }
        distributionDict = gameDistribution
    }
    
    init(gameThrows:DartGame) {
        
        game = gameThrows
        
        generateDistributionDict()
        
        // Initialise the Distribution Analyser and Analyse the game's distribution dictionary
        let analyser = DistributionAnalyser(distributionDict)
        mostCommonHit = analyser.mostCommonHit
        mostCommonSection = analyser.mostCommonSection
        leastCommonHit = analyser.leastCommonHit
        leastCommonSection = analyser.leastCommonSection
    }
}

// MARK: DartGame
/**
 *  The top level container for DartHits, a list of DartTurns
 *  Includes any useful/handy functions associated
 */
struct DartGame:Saveable { // Friday 27 May 2016
    var allTurns:[DartTurn] = []
    
    /// Returns an array of DartHits by iterating over all turns and reading their array of turns and summing the arrays
    var allThrows:[DartHit] {
        get {
            return allTurns.map {$0.protectedThrows}.reduce([], combine: +)
        }
    }
    
    /// Implementation of Saveable
    var saveDataDict:[String:AnyObject] {
        get {
            return allTurns.map {
                $0.saveDataDict
                }.toDict
        }
    }
    
    /// Returns a dictionary where the key is the string of the index and the value is an instance of Achievement
    var allAchievements:[String:Achievement] {
        get {
            var allAch:[String:Achievement] = [:]
            for i in 0..<allTurns.count {
                if let ach = allTurns[i].achievement {
                    allAch[i.toString] = ach
                }
            }
            return allAch
        }
    }
    
    /// Returns the number of turns in a game (rounds up)
    var numTurns:Int {
        get {
            return allTurns.count
        }
    }
    
    /**
     Adds a turn to the game, while checking that there are actual throws in the turn
     
     - parameter turn: The DartTurn to be added to the game
     */
    mutating func addTurn(turn:DartTurn) {
        if turn.numThrows > 0 {
            allTurns.append(turn)
        }
    }
}

// MARK: DartTurn
/**
 *  The middle level container for DartHits, a list of DartHits
 *  Includes searching for Achievements, and other handy functions required
 */
struct DartTurn:Saveable { // Friday 27 May 2016
    private var allThrows:[DartHit] = []
    
    /// Read only exposure of the array of DartHits
    var protectedThrows:[DartHit] {
        get {
            return allThrows
        }
    }
    
    /// Read only exposure of the number of throws in the turn
    var numThrows:Int {
        get {
            return allThrows.count
        }
    }
    
    /// Read only of the sum of the points scored in a turn
    var turnTotal:UInt {
        get {
            return allThrows.map {$0.section * $0.multiplier}.reduce(0, combine: +)
        }
    }
    
    /// Read only of whetehr or not the user busted in the turn
    var didBust:Bool {
        get {
            return allThrows.filter {$0.didBust}.count > 0
        }
    }
    
    /**
     Check if all the throws landed in a certain secton of the dartboard
     
     - parameter section: The section to be checked against
     
     - returns: A boolean, true if they all did, false if they didn't land in that section
     */
    func isAllInSection(section:UInt) -> Bool {
        return allThrows.filter {$0.section == section}.count == allThrows.count
    }
    
    /**
     Check if all the throws landed in a certain multiplier of the dartboard
     
     - parameter multiplier: The multiplier to be checked against
     
     - returns: A boolean, true if they all did, false if they didn't land in that multiplier
     */
    func isAllInMultiplier(multiplier:UInt) -> Bool {
        return allThrows.filter {$0.multiplier == multiplier}.count == allThrows.count
    }
    
    // MARK: Analysing DartTurn for Achievements
    /**
     *  Read only, and private, so only accessible within this DartTurn struct
     *  Requirements: a score between 100 and 150 inclusive
     */
    private var isLowTon:Bool {
        get {
            return turnTotal >= 100 && turnTotal <= 150
        }
    }
    
    /**
     *  Read only, and private, so only accessible within this DartTurn struct
     *  Requirements: a score higher than 150
     */
    private var isHighTon:Bool {
        get {
            return turnTotal > 150
        }
    }
    
    /**
     *  Read only, and private, so only accessible within this DartTurn struct
     *  Requirements: A score of 180
     */
    private var isTon80:Bool {
        get {
            return turnTotal == 180
        }
    }
    
    /**
     *  Read only, and private, so only accessible within this DartTurn struct
     *  Requirements: All throws land in either a double or triple a single section
     */
    private var isThreeInABed:Bool {
        get {
            return isAllInMultiplier(allThrows.first!.multiplier) && isAllInSection(allThrows.first!.section) && numThrows == 3 && allThrows.first!.multiplier > 1
        }
    }
    
    /**
     *  Read only, and private, so only accessible within this DartTurn struct
     *  Requirements: Three Bulls Eye throws
     */
    private var isHatTrick:Bool {
        get {
            return isAllInSection(25) && numThrows == 3
        }
    }
    
    /**
     *  Read only, and private, so only accessible within this DartTurn struct
     *  Requirements: Three Double Bulls Eye throws
     */
    private var isThreeInTheBlack:Bool {
        get {
            return isHatTrick && isAllInMultiplier(2) && numThrows == 3
        }
    }
    
    /* Need to know if the game is cricket.
     private var isWhiteHorse:Bool {
     get {
     return isAllInMultiplier(3)
     }
     }
     */
    
    /// Returns an Achievement instance if an achievement was achieved, otherwise return Nil
    var achievement:Achievement? {
        get {
            if isTon80 {
                return .Ton80
            }
            if isThreeInTheBlack {
                return .ThreeInTheBlack
            }
            if isHatTrick {
                return isHighTon ? .HatTrickHT : (isLowTon ? .HatTrickLT : .HatTrick)
            }
            if isThreeInABed {
                return .ThreeInABed
            }
            if isHighTon {
                return .HighTon
            }
            if isLowTon {
                return .LowTon
            }
            return nil
        }
    }
    // MARK: End Achievements
    
    /// Implementation of the Saveable protocol
    var saveDataDict:[String:AnyObject] {
        get {
            return allThrows.map {
                $0.saveDataDict
                }.toDict
        }
    }
    
    /// Returns the short names of all the throws in the turn in an array
    var shortNames:[String] {
        get {
            return allThrows.map { $0.shortString }
        }
    }
    
    /// Returns the medium length names of all the throws in the turn in an array
    var mediumNames:[String] {
        get {
            return allThrows.map { $0.mediumString }
        }
    }
    
    /**
     Add a score to this turn if there are less than 3 throws already
     
     - parameter hit: The DartHit to be added to this turn
     */
    mutating func addThrow(hit:DartHit) {
        if allThrows.count < 3 { allThrows.append(hit) }
    }
    
    /**
     Initialise a DartTurn with an optional array of hits
     
     - parameter arrThrows: Array of DartHits (Optional)
     
     - returns: Intialised DartTurn (self)
     */
    init(arrThrows:[DartHit]? = nil) {
        if arrThrows != nil {
            if arrThrows!.count <= 3 {
                allThrows = arrThrows!
            } else { print("Too many throws to add") }
        }
    }
}

// MARK: Dart Hit
/**
 *  The most basic format for keeping a Dart hit in memory
 *  Contains the hit section and multiplier, with associated variables
 *  such as total hit value, bust reason, etc.
 */
struct DartHit:Saveable { // Tuesday 24 May 2016
    let section:UInt!
    let multiplier:UInt!
    let totalHitValue:UInt!
    enum ZeroHitReason:String {
        case Bust = "Bust"
        case NotOpenCriteria = "Not Close Criteria"
        case Missed = "Missed"
    }
    var reason:ZeroHitReason?
    var didBust:Bool {
        get {
            return reason != nil
        }
    }
    
    /// Implementation of the Saveable protocol
    var saveDataDict:[String:AnyObject] {
        get {
            // Only save the fundamental hit data, as the rest can be reconstructed later.
            var toReturn:[String:AnyObject] = [
                "section":section,
                "multiplier":multiplier
            ]
            
            // If this throw caused a bust or something similar, add it in as "reason"
            if didBust {
                toReturn["reason"] = reason!.rawValue
            }
            return toReturn
        }
    }
    
    /// The short name of a hit i.e. S 20; as a String
    var shortString:String {
        get {
            let multipliers = ["S", "D", "T"]
            return "\(multipliers[Int(multiplier - 1)]) \(section)"
        }
    }
    
    /// The medium name of a hit i.e. Single 20; as a String
    var mediumString:String {
        get {
            let multipliers = ["Single", "Double", "Triple"]
            return "\(multipliers[Int(multiplier - 1)]) \(section)"
        }
    }
    
    /**
     Initialise the DartHit, with a hit section and multiplier
     
     - parameter hitSection:    A number from 1-20, and 25
     - parameter hitMultiplier: A number from 1-3, and up to 2 for section 25
     
     - returns: Intialised DartHit with extrapolated values (self)
     */
    init(hitSection:UInt, hitMultiplier:UInt) {
        section = hitSection
        multiplier = hitMultiplier
        // Since section and multiplier are not mutable, just calculate the totalHitValue once here.
        totalHitValue = section * multiplier
    }
}