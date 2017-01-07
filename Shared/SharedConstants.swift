//
//  SharedConstants.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 8/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

/// The number that the timestamp is divided and multiplied by to save and read the game
let timestampFactor = 100000.0

/// Theme Colours
let kColorRed = UIColor(r: 233, g: 79, b: 55)
let kColorWhite = UIColor(r: 246, g: 247, b: 235)
let kColorBlack = UIColor(r: 57, g: 62, b: 65)
let kColorBlue = UIColor(r: 63, g: 136, b: 197)
let kColorGreen = UIColor(r: 68, g: 187, b: 164)

/**
 A container for the 4 types of games available, and their sub types.
 Saves me from having to deal with error prone string literals
 Especially handy for conditionals, since with so many options it could get out of hand, this wraps it all up nicely
 This is also great for consistent game name handling throughout the program.
 
 - Free:      Title will be "Free \(numRounds)"
 - Countdown: Title will be "Countdown \(startValue)"
 - Cricket:   Title will be "Cricket" or "Cut-Throat Cricket"
 - World:     Title will be "World"
 - FromTitle: A backwords conversion to return the gameType of the string entered, i.e. .FromTitle("Free 5").gameType = .Free(5)
 - author: Jordan Lewis
 - date: Saturday 28 May 2016
 - todo: N/A
 */
enum GameType {
    case Free(rounds:Int)
    case Countdown(startValue:UInt)
    case Cricket(cutThroat:Bool)
    case World
    case FromTitle(aTitle:String)
    
    /// Returns the class of a game type, WARNING, use with .FromTitle will return nil, to do that do .FromTitle().gameType.gameClass!
    var gameClass:GameClass? {
        switch self {
        case .Free:
            return .Free
        case .Countdown:
            return .CountDown
        case .Cricket:
            return .Cricket
        case .World:
            return .World
        default:
            return nil
        }
    }
    
    /// Only for use with .FromTitle, to get game types
    var gameType:GameType {
        switch self {
        case .FromTitle(let aTitle):
            let parts = aTitle.componentsSeparatedByString(" ")
            if parts.contains("Free") {return .Free(rounds: parts.last!.toInt()!)}
            if parts.contains("Countdown") {return .Countdown(startValue: UInt(parts.last!.toInt()!))}
            if parts.contains("Cricket") {return .Cricket(cutThroat: parts.contains("Cut-Throat"))}
            if parts.contains("World") {return .World}
        default:
            break
        }
        return self
    }
    
    /// The string representation of game types
    var title:String? {
        switch self {
        case .Free(let rounds):
            return "Free \(rounds)"
        case .Countdown(let startValue):
            return "Countdown \(startValue)"
        case .Cricket(let cutThroat):
            return "\(cutThroat ? "Cut-Throat ":"")Cricket"
        case .World:
            return "World"
        default:
            return nil
        }
    }
}

/**
 A container for the 4 classes of games available
 Saves me from having to deal with error prone string literals
 Especially handy for conditionals
 
 
 - CountDown: Raw Value is "01"
 - Cricket:   Raw Value is "Cricket"
 - Free:      Raw Value is "Free"
 - World:     Raw Value is "World"
 */
enum GameClass:String {
    case CountDown = "01"
    case Cricket = "Cricket"
    case Free = "Free"
    case World = "World"
}