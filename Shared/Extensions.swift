//
//  Extensions.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 27/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit

// MARK: Handy Extensions
extension IntegerType {
    /**
     Converts an Integer into a String
     
     - author: Jordan Lewis
     - date: Wednesday 25 May 2016
     - returns: A string with the integer in it.
     - todo: None
     */
    var toString:String {
        return "\(self)"
    }
}

extension Array {
    /**
     Converts an Array into a dictionary
     where its keys are the string value of the index of the object in the array
     
     - author: Jordan Lewis
     - date: Wednesday 25 May 2016
     - returns: A dictionaries with keys the string value of the index of the object in the array
     - todo: None
     */
    var toDict:[String:Element] {
        var dict:[String:Element] = [:]
        for i in 0..<self.count {
            dict[i.toString] = self[i]
        }
        return dict
    }
}

extension UIView {
    /**
     For applying a consistent drop shadow to all views
     */
    func applyDropShadow() {
        self.layer.shadowColor = kColorBlack.CGColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSizeMake(-20, 20)
        self.layer.shadowRadius = 25
    }
}