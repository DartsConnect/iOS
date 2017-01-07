//
//  UserStruct.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 27/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation

// MARK: User data
/**
 *  A container for User data
 */
struct User { // Tuesday 24 May 2016
    var cardID:String!
    var username:String!
    var uid:String?
    var isGuest:Bool {
        get {
            return cardID.containsString("Guest")
        }
    }
}

