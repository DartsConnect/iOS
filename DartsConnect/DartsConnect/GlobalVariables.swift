//
//  GlobalVariables.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 7/07/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

private let _sharedGlobalVariables = GlobalVariables()

/**
 *  This is a Singleton file/class, if you're not sure what it is,
 *  its just a class that only ever has one instance in the program
 */
class GlobalVariables:NSObject {
    
    var achievements:[String:[String:[String:[String]]]]?
    
    var currentGameDataDict:[String:AnyObject]?
    
    var uid:String = ""
    var dbManager:DatabaseManager = DatabaseManager(authenticateAnonymously: false)
    
    class var sharedVariables: GlobalVariables {
        return _sharedGlobalVariables
    }
}