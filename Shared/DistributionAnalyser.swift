//
//  DistributionAnalyser.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 8/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
/**
 *  In iOS the EZSwiftExtensions framework is added as a CocoaPod, so must be manually imported into this file.
 *  tvOS does not require an import since the files where manually added to the project.
 *
 *  @param iOS The OS this program is running on.
 *
 *  @return No Return value, just imports EZSwiftExtensions
 */
#if os(iOS)
    import EZSwiftExtensions
#endif

/**
 *  A struct for finding the most & least common hits from a distribution dictionary.
 */
struct DistributionAnalyser {
    let distributionDict:DistributionDict
    var mostCommonHit:[DartHit] = []
    var mostCommonSection:[Int] = []
    var leastCommonHit:[DartHit] = []
    var leastCommonSection:[Int] = []
    
    /**
     Finds the most common his from the distribution dictionary by starting from 0 hits and moving up
     It will return an array since there could possibly be more than one hit with the same number of occurances
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - returns: An array of all the most common DartHits
     - todo: None
     */
    private func findMostCommonHit() -> [DartHit] {
        var highest:(DartHit, Int) = (DartHit(hitSection: 1, hitMultiplier: 1), 0)
        var othersAtSame:[DartHit] = []
        
        /*
         go through every section and find the multiplier that has been hit most
         if that is higher than the current highest, swap, if it is equal, add it to the othersAtSame
         otherwise ignore
         */
        for (section, sectionDict) in distributionDict {
            
            /* Find the highest multiplier */
            var highestMultiplier:(String, Int) = ("1", 0)
            for (multi, hitCount) in sectionDict {
                if hitCount > highestMultiplier.1 {
                    highestMultiplier = (multi, hitCount)
                }
            }
            
            
            if highestMultiplier.1 > highest.1 {
                // Set the new highest
                othersAtSame.removeAll()
                highest = (DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(highestMultiplier.0)!), highestMultiplier.1)
                
            } else if highestMultiplier.1 == highest.1 { // If the highest multiplier here is the same as the current multiplier
                // Add it onto the array of highest hits
                othersAtSame.append(DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(highestMultiplier.0)!))
            }
        }
        othersAtSame.append(highest.0)
        return othersAtSame
    }
    
    /**
     Finds the least common hit from the distribution dictionary by working down from the highest.
     This function ignores any sections that were not hit.
     It will return an array since there could possibly be more than one hit with the same number of occurances
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - returns: An array of all the least common DartHits
     - todo: None
     */
    private func findLeastCommonHit() -> [DartHit] {
        // Start from the highest and work down
        let mostCommon = mostCommonHit.first!
        var lowest:(DartHit, Int) = (mostCommon, distributionDict[mostCommon.section.toString]![mostCommon.multiplier.toString]!)
        
        var othersAtSame:[DartHit] = []
        
        for (section, sectionDict) in distributionDict {
            
            /* Find the highest multiplier */
            var highestMultiplier:(String, Int) = ("1", 0)
            for (multi, hitCount) in sectionDict {
                if hitCount > highestMultiplier.1 {
                    highestMultiplier = (multi, hitCount)
                }
            }
            
            // Find the lowest multiplier by working down from the highest and as long as it does not = 0
            var lowestMultiplier:(String, Int) = highestMultiplier
            for (multi, hitCount) in sectionDict {
                if hitCount > 0 {
                    if hitCount < lowestMultiplier.1 {
                        lowestMultiplier = (multi, hitCount)
                    }
                }
            }
            
            
            // Make sure that even the highest is not 0
            if lowestMultiplier.1 > 0 {
                if lowestMultiplier.1 < lowest.1 {
                    // Set the new lowest
                    othersAtSame.removeAll()
                    lowest = (DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(lowestMultiplier.0)!), lowestMultiplier.1)
                } else if lowestMultiplier.1 == lowest.1 {
                    // Add it onto the array of least common hits
                    othersAtSame.append(DartHit(hitSection: UInt(section)!, hitMultiplier: UInt(lowestMultiplier.0)!))
                }
            }
        }
        othersAtSame.append(lowest.0)
        return othersAtSame
    }
    
    /**
     Finds the most common section by summing the number of hits in each multiplier
     It will return an array since there could possibly be more than one hit with the same number of occurances
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - returns: An array of integers representing the area that got hit, i.e. [1,2,3]
     - todo: None
     */
    private func findMostCommonSection() -> [Int] {
        var othersAtSame:[Int] = []
        var highest:(Int, Int) = (0, 0) // Start at 0 hits
        for (section, sectionDict) in distributionDict { // For every section (1-20, 25)
            let currentCount:Int = sectionDict.map {$0.1}.reduce(0, combine: +) // Sum the total hits in the section
            if currentCount > highest.1 {
                // Set the current as the highest
                othersAtSame.removeAll()
                highest = (section.toInt()!, currentCount)
            } else if currentCount == highest.1 {
                // If the number of occurances is the same, add it to the end of the array
                othersAtSame.append(section.toInt()!)
            }
        }
        othersAtSame.append(highest.0)
        return othersAtSame
    }
    
    /**
     Find the least common section by working down from the highest.
     It will return an array since there could possibly be more than one hit with the same number of occurances
     
     - author: Jordan Lewis
     - date: Friday 27 May 2016
     - returns: An array of integers representing the area that got hit, i.e. [1,2,3]
     - todo: None
     */
    private func findLeastCommonSection() -> [Int] {
        var othersAtSame:[Int] = []
        
        // Work from most common then go down
        let mostCommon = distributionDict[mostCommonSection.first!.toString]!.map{$0.1}.reduce(0, combine: +)
        var lowest:(Int, Int) = (mostCommonSection.first!, mostCommon)
        
        for (section, sectionDict) in distributionDict { // For every section (1-20, 25)
            
            // Sum of the hits in that section
            let currentCount = sectionDict.map {$0.1}.reduce(0, combine: +)
            
            if currentCount > 0 { // Make sure the hit count is greater than 0
                if currentCount < lowest.1 {
                    // Set the current as the lowest
                    othersAtSame.removeAll()
                    lowest = (section.toInt()!, currentCount)
                } else if currentCount == lowest.1 {
                    // If the number of occurances it the same, add it to the end of the array
                    othersAtSame.append(section.toInt()!)
                }
            }
        }
        
        othersAtSame.append(lowest.0)
        return othersAtSame
    }
    
    /**
     Initialise the DistributionAnalyser, and in the process,
     find the most & least common hits & sections
     
     - parameter dist: A read ready distribution dictionary
     
     - returns: An initialised instance of DistributionAnalyser; (self)
     */
    init(_ dist:DistributionDict) {
        distributionDict = dist
        
        mostCommonHit = findMostCommonHit()
        mostCommonSection = findMostCommonSection()
        leastCommonHit = findLeastCommonHit()
        leastCommonSection = findLeastCommonSection()
    }
}