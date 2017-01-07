//
//  Achievement.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 7/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

// Saturday 28 May 2016
/// Back and forth conversion structure for achievements to minimise handling string literals in code.
indirect enum Achievement {
    case Ton80, HighTon, LowTon, HatTrick, ThreeInTheBlack, ThreeInABed, HatTrickLT, HatTrickHT
    
    /// The String of the short names of the Achievements, to save storage space.
    var shortName:String {
        get {
            switch self {
            case .Ton80:
                return "t80"
            case .HighTon:
                return "hTon"
            case .LowTon:
                return "lTon"
            case .HatTrick:
                return "HT"
            case .HatTrickLT:
                return "HT&lTon"
            case .HatTrickHT:
                return "HT&hTon"
            case .ThreeInTheBlack:
                return "3itB"
            case .ThreeInABed:
                return "3iaB"
            }
        }
    }
    
    // The full namae of an Achievement, to show the user.
    var fullName:String {
        get {
            switch self {
            case .Ton80:
                return "Ton 80"
            case .HighTon:
                return "High Ton"
            case .LowTon:
                return "Low Ton"
            case .HatTrick:
                return "Hat Trick"
            case .HatTrickLT:
                return "Hat Trick & Low Ton"
            case .HatTrickHT:
                return "Hat Trick & High Ton"
            case .ThreeInTheBlack:
                return "Three in the Black"
            case .ThreeInABed:
                return "Three in a Bed"
            }
        }
    }
    
    // Allows the creation of this enum from a short name string
    init?(shortName:String) {
        switch shortName {
        case "t80": self = .Ton80
        case "hTon": self = .HighTon
        case "lTon": self = .LowTon
        case "HT": self = .HatTrick
        case "HT&lTon": self = .HatTrickLT
        case "HT&hTon": self = .HatTrickHT
        case "3itB": self = .ThreeInTheBlack
        case "3iaB": self = .ThreeInABed
        default:
            return nil
        }
    }
    
    // Allows the creation of this enum from a long name string
    init?(longName:String) {
        switch longName {
        case "Ton 80": self = .Ton80
        case "High Ton": self = .HighTon
        case "Low Ton": self = .LowTon
        case "Hat Trick": self = .HatTrick
        case "Hat Trick & Low Ton": self = .HatTrickLT
        case "Hat Trick & High Ton": self = .HatTrickHT
        case "Three in the Black": self = .ThreeInTheBlack
        case "Three in a Bed": self = .ThreeInABed
        default:
            return nil
        }
    }
}