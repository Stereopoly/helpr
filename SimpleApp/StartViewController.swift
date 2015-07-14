//
//  StartViewController.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 6/23/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import ParseUI
import ParseFacebookUtilsV4
import SwiftSpinner

var fbUsername: String = ""

class StartViewController: UIViewController, FBSDKLoginButtonDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        var loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "user_friends"]
        let size = 240 as CGFloat
        let screenwidth = self.view.frame.size.width
        loginButton.frame = CGRectMake(screenwidth/2 - size/2, 400, size, 50)
        //loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        beginIgnore()
        addSpinner("Logging in", Animated: true)
        delay(seconds: 1.0) { () -> () in
            
            if error == nil {
                println("Login complete.")
                let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                
                request.startWithCompletionHandler {
                    
                    (connection, result, error) in
                    
                    if error != nil {
                        // Some error checking here
                        println("Error in user request")
                        self.addSpinner("Error", Animated: false)
                        self.delay(seconds: 1.0, completion: { () -> () in
                            self.hideSpinner()
                            self.endIgnore()
                        })
                    }
                    else if let userData = result as? [String:AnyObject] {
                        
                        // Access user data
                        let username = userData["name"] as? String
                        fbUsername = username!
                        println(username)
                        self.addSpinner("Success", Animated: false)
                        self.delay(seconds: 1.0, completion: { () -> () in
                            self.hideSpinner()
                            self.endIgnore()
                            self.performSegueWithIdentifier("toTabBarController", sender: self)
                        })
                    }
                }
                
            }
            else {
                self.addSpinner("Error in login", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    println(error.localizedDescription)
                    self.hideSpinner()
                })
                
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User logged out...")
    }
    
    
    // MARK: - Activity Indicator
    
    func addSpinner(Error: String, Animated: Bool) {
        SwiftSpinner.show(Error, animated: Animated)
    }
    
    func hideSpinner() {
        SwiftSpinner.hide()
    }
    
    func delay(#seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    func beginIgnore() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    func endIgnore() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
