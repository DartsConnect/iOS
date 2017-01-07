//
//  ViewController.swift
//  DartsConnect
//
//  Created by Jordan Lewis on 21/05/2016.
//  Copyright © 2016 Jordan Lewis. All rights reserved.
//

import UIKit
import SVProgressHUD
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet var logo: UIImageView!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    /**
     Called whent the login button is pressed on the login screen
     Will login and authenticate the user, if it fails, it will show an error to the user
     
     - parameter sender: The instance of the button that called it.
     */
    @IBAction func login(sender: UIButton) {
        let shouldLogin = true // For debugging to not have to wait for the login
        if shouldLogin {
            SVProgressHUD.show()
            
            // Run the login function to authenticate the user and get the user's UID for accessing data later.
            GlobalVariables.sharedVariables.dbManager.loginTo(emailField.text!, password: passwordField.text!, completion: {
                error, uid in
                
                if error == nil {
                    GlobalVariables.sharedVariables.uid = uid!
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("Logging In", sender: self)
                        SVProgressHUD.dismiss()
                    })
                } else {
                    print("Login error: \(error!.description)")
                    dispatch_async(dispatch_get_main_queue(), {
                        SVProgressHUD.showErrorWithStatus("Failed to login")
                    })
                }
                
            })
        } else {
            // Also for debuggin, the UID here is that for 38559@joeys.org (username: Jordan)
            GlobalVariables.sharedVariables.uid = "5cb155dd-42dd-42b7-9e44-e85d1e4d0e20"
            self.performSegueWithIdentifier("Logging In", sender: self)
        }
    }
    
    /**
     INCOMPLETE IMPLEMENTATION
     Will tell the server to send a new password to the user's email address.
     
     - parameter sender: The instance of the button that called it.
     */
    @IBAction func forgotPassword(sender: UIButton) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

