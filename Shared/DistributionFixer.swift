//
//  DistributionFixer.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 8/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

/**
 *  Due to the way Firebase handles keys like "1" or "2"
 *  in converting it to 1, 2 as numbers, I had to add an "_"
 *  before it, to prevent this type conversion.
 *  The sole purpose of this struct is to convert back and forth
 *  between the two formats, because I want "1" as keys rather than "_1"
 */
struct DistributionFixer {
    private let prefix:String = "_"
    
    /**
     Add the prefix "_" to the data
     
     - parameter dist: A Distribution Dictionary with keys like "1"
     
     - returns: A save safe formatted version of the data with keys like "_1".
     */
    func fixKeysToSave(dist:DistributionDict) -> DistributionDict {
        var newDist:DistributionDict = [:]
        for (sectionKey, sectionValue) in dist {
            var newSectionValue:[String:Int] = [:]
            for (areaKey, areaValue) in sectionValue {
                newSectionValue["\(prefix)\(areaKey)"] = areaValue
            }
            newDist["\(prefix)\(sectionKey)"] = newSectionValue
        }
        return newDist
    }
    
    /**
     Strips the prefix "_" from the keys for the data
     
     - parameter dist: A Distribution Dictionary with keys like "_1"
     
     - returns: A read ready formatted version of the data with keys like "1"
     */
    func fixKeysToRead(dist:DistributionDict) -> DistributionDict {
        var newDist:DistributionDict = [:]
        for (sectionKey, sectionValue) in dist {
            var newSectionValue:[String:Int] = [:]
            for (areaKey, areaValue) in sectionValue {
                newSectionValue[areaKey.stringByReplacingOccurrencesOfString(prefix, withString: "")] = areaValue
            }
            newDist[sectionKey.stringByReplacingOccurrencesOfString(prefix, withString: "")] = newSectionValue
        }
        return newDist
    }
}