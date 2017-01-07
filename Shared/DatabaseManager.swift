//
//  DatabaseManager.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 15/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import Foundation
import Firebase

struct DatabaseManager {
    let rootRef = Firebase(url: "https://dartsconnect.firebaseio.com")
    
    enum UserRegistrationError:ErrorType {
        case CardAlreadyRegistered
    }
    
    /**
     Initiate the Database Manager
     
     - parameter authenticateAnonymously: whether or not the DatabaseManager should authenticate anonymously on connect
     
     - returns: The initiated instance of DatabaseManger
     */
    init(authenticateAnonymously:Bool) {
        if authenticateAnonymously {
            rootRef.authAnonymouslyWithCompletionBlock({
                error, authData in
                if error == nil {
                    print("Firebase authenticated anonymously")
                } else {
                    // This should never happen, as AppleTVs are assumed to be connected to a highspeed Internet connection
                    // However, something should be implemented to tell the user of this isssue.
                    print("Uh oh, Firebase failed to authenticate anonymously... what should I do? Here is the error message \(error!.description)")
                }
            })
        }
    }
}

// MARK: Account Creation
extension DatabaseManager {
    /**
     Logs into the provided account details and calls a callback block with an optional error and uid string
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameter email:      The user's email address
     - parameter password:   The user's password
     - parameter completion: A callback function, where both error and uid are Optionals.
     - returns: None
     - todo: None
     */
    func loginTo(email:String, password:String, completion:(error:NSError?, uid:String?) -> Void) {
        rootRef.authUser(email, password: password, withCompletionBlock: {
            error, authData in
            if authData != nil {
                completion(error: error, uid: authData.uid)
            } else {
                completion(error: error, uid: nil)
            }
        })
    }
    
    /**
     Resets the password for an account.
     Then, on completion of that, will authenticate the user to check.
     
     - author: Jordan Lewis
     - date: Thursday 19 May 2016
     - parameter email:      The email address of the account that's password must be changed
     - parameter tempPass:   The temporary password sent by Firebase
     - parameter newPass:    The new password
     - parameter completion: An option callback, which returns a uid upon completion, or nil for failure.
     - returns: None
     - todo: None
     */
    func resetPasswordFor(email:String, tempPass:String, newPass:String, completion:(error:NSError?, uid:String?) -> Void) {
        rootRef.changePasswordForUser(email, fromOld: tempPass, toNew: newPass, withCompletionBlock: {
            error in
            if error == nil {
                self.rootRef.authUser(email, password: newPass, withCompletionBlock: {
                    error, authData in
                    completion(error: error, uid: authData.uid)
                })
            } else {
                completion(error: error, uid: nil)
            }
        })
    }
    
    /**
     Queries the database to see if the username a user entered is already taken or not.
     Processing is done by Firebase.
     
     - author: Jordan Lewis
     - date: Wednesday 18 May 2016
     - parameter username:   String containing a username that the user wants
     - parameter completion: An optional callback with a boolean variable reflecting the availability of the username provided
     - returns: Bool, if the username is available or not.
     - todo: None
     */
    func isUsernameAvailable(username:String, completion:(isAvailable:Bool) -> Void) {
        let ref = rootRef.childByAppendingPath("usernames")
        
        ref.queryEqualToValue(username).observeSingleEventOfType(.Value, withBlock: {
            dataSnapshot in
            completion(isAvailable: dataSnapshot.value is NSNull)
        })
    }
}

// MARK: Fetching Data
extension DatabaseManager {
    /**
     Fetches the UID for the Card ID provided
     This function allows the data returned from Firebase to be read either by an asynchronous callback or main thread blocking value return
     It will decide based on whether or not a callback was assigned.
     
     - author: Jordan Lewis
     - date: Tuesday 24 May 2016
     - parameter cardID:     Card ID to look up
     - parameter completion: An optional completion called upon success or failure
     - returns: An optional string containing the data lookup
     - todo: None
     */
    func getUIDForCardID(cardID:String, completion:((uid:String) -> Void)? = nil) -> String? {
        let cardIDtoUIDPath = "cardID-UID/\(cardID)"
        if completion == nil {
            return self.getDataWithPath(cardIDtoUIDPath) as? String
        } else {
            self.getDataWithPath(cardIDtoUIDPath) {
                data in
                completion!(uid:data as! String)
            }
        }
        return nil
    }
    
    /**
     Fetches the data at the path provided from the root of Firebase
     This function allows the data returned from Firebase to be read either by an asynchronous callback or main thread blocking value return
     It will decide based on whether or not a callback was assigned.
     
     - author: Jordan Lewis
     - date: Tuesday 24 May 2016
     - parameter path:       The path to lookup
     - parameter completion: An optional completion method containing a optional data value returned from Firebase
     - returns: An optional AnyObject containing the data received
     - todo: None
     */
    func getDataWithPath(path:String, completion:((data:AnyObject?) -> Void)? = nil) -> AnyObject? {
        let ref = rootRef.childByAppendingPath(path)
        return getDataFromReference(ref, completion: completion)
    }
    
    /**
     Get the data from a Firebase Reference
     This function allows the data returned from Firebase to be read either by an asynchronous callback or main thread blocking value return
     It will decide based on whether or not a callback was assigned.
     
     - author: Jordan Lewis
     - date: Wednesday 06 July 2016
     - parameter ref:        Firebase Reference to read the data from
     - parameter completion: An optional completion callback containing a optional data value returned from Firebase
     - returns: An optional AnyObject containing the data received
     - todo: None
     */
    func getDataFromReference(ref:Firebase, completion:((data:AnyObject?) -> Void)? = nil) -> AnyObject? {
        var semaphore:dispatch_semaphore_t?
        var data:AnyObject?
        if completion == nil {
            semaphore = dispatch_semaphore_create(0)
        }
        ref.observeSingleEventOfType(.Value, withBlock: {
            dataSnapshot in
            let value = dataSnapshot.value
            if completion == nil {
                data = value
                dispatch_semaphore_signal(semaphore!)
            } else {
                //                print(dataSnapshot.key)
                //                print(dataSnapshot)
                //                print(dataSnapshot.children)
                //                print("---")
                completion!(data: value)
            }
        })
        if completion == nil {
            dispatch_semaphore_wait(semaphore!, DISPATCH_TIME_FOREVER)
        }
        return data
    }
    
    /**
     Get the card owner's username
     This function allows the data returned from Firebase to be read either by an asynchronous callback or main thread blocking value return
     It will decide based on whether or not a callback was assigned.
     
     - author: Jordan Lewis
     - date: Friday 20 May 2016, Rewritten Tuesday 24 May 2016
     - parameter cardID:     The Card ID to look up
     - parameter completion: An optional completion callback containing a option username value returned from Firebase
     - returns: An optional string containing the data received
     - todo: None
     */
    func getUsernameForCardID(cardID:String, completion:((username:String?) -> Void)? = nil) -> String? {
        var username:String?
        var sema:dispatch_semaphore_t?
        if completion == nil {
            sema = dispatch_semaphore_create(0)
        }
        getDataWithPath("cardID-UID/\(cardID)") { // First get the user's UID
            uidData in
            self.getDataWithPath("users/\(uidData as! String)/username") { // Then use the UID to look up the user's username
                usernameData in
                let unwrapped = usernameData as! String
                if completion == nil {
                    username = unwrapped
                    dispatch_semaphore_signal(sema!)
                } else {
                    completion!(username: unwrapped)
                }
            }
        }
        if completion == nil {
            dispatch_semaphore_wait(sema!, DISPATCH_TIME_FOREVER)
        }
        return username
    }
}