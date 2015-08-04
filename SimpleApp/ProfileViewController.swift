//
//  ProfileViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/14/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import ParseUI
import ParseFacebookUtilsV4
import SwiftSpinner

var name = ""

var myRequestedTask: String = ""

var justVerified:Bool = false

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var taskPending: Bool = false
    
    var currentUserPoints = 0
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var taskLabel: UILabel!
    
    @IBOutlet weak var acceptedLabel: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var withdrawButton: UIButton!
    
    @IBOutlet weak var closeRequestButton: UIButton!
    
    @IBAction func closeRequestButtonPressed(sender: AnyObject) {
        if taskPending == true {
            closeRequestAlert()
            
        } else {
            self.performSegueWithIdentifier("toCloseRequest", sender: self)
        }
        
    }
    
    @IBAction func withdrawButtonPressed(sender: AnyObject) {
        println("Pressed")
        recievedAlert()
    }
    
    var slow: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSpinner("Loading", Animated: true)
        self.beginIgnore()
        
        // Do any additional setup after loading the view.
        nameLabel.hidden = true
        taskLabel.hidden = true
        acceptedLabel.hidden = true
        nameLabel.hidden = false
        
        withdrawButton.hidden = true
        closeRequestButton.hidden = true
        
        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
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
                self.addSpinner("Done", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    self.nameLabel.text = fbUsername
                    self.getTask()
                    self.getAccepted()
                    self.getPoints()
                    self.hideSpinner()
                    self.endIgnore()
                })
            }
            
        }
        var loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile"]
        let size = self.view.frame.size.width  as CGFloat
        let screenwidth = self.view.frame.size.width
        let screenheight = self.view.frame.height
        loginButton.frame = CGRectMake(screenwidth/2 - size/2, screenheight - 107, size, 50)
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        withdrawButton.layer.cornerRadius = 4
        closeRequestButton.layer.cornerRadius = 4
        if justVerified == true {
            justVerified = false
            
            self.taskLabel.text = "None."
            self.taskLabel.hidden = false
            self.closeRequestButton.hidden = true
            
            getTask()
            getAccepted()
            getPoints()
            
        } else {
            getTask()
            getAccepted()
            getPoints()
        }
    }
    
    func onTimer() {
        getTask()
        getAccepted()
        getPoints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeRequestAlert() {
        let title = "Are you sure you want to close your request?"
        let message = ""
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Yes"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
            self.taskLabel.text = "None."
            self.taskLabel.hidden = false
            self.closeRequestButton.hidden = true
            
            self.closeRequest()
            
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func closeRequest() {
        var objectId = ""
        
        var query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        query.whereKey("task", equalTo: myRequestedTask)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    println(objects)
                    for object in objects {
                        objectId = object.objectId as! String!
                        println("ObjectId: \(objectId)")
                    }
                }
                
                var query2 = PFQuery(className: "request")
                query2.getObjectInBackgroundWithId(objectId, block: { (task, error) -> Void in
                    if let task = task {
                        task.deleteInBackgroundWithBlock({ (delete, error) -> Void in
                            if error != nil {
                                println("Error closing request")
                                self.addSpinner("Error closing request", Animated: false)
                                self.delay(seconds: 1.0, completion: { () -> () in
                                    self.hideSpinner()
                                    self.endIgnore()
                                })
                            } else {
                                println("Success closing request")
                            }
                        })
                    } else {
                        println("Error in object retrival")
                    }
                })
            } else {
                println("Error in object request")
            }
            
        }
        
    }
    
    /// Show an alert with an "Okay" and "Cancel" button.
    func recievedAlert() {
        let title = "Are you sure?"
        let message = ""
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Yes"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
            
            self.addSpinner("Withdrawing...", Animated: true)
            self.beginIgnore()
            
            var objectId = ""
            println("Withdraw")
            self.withdrawButton.enabled = false
            
            var query = PFQuery(className: "request")
            query.whereKey("requester", equalTo: name)
            
            let objects = query.findObjects()
            if objects != nil {
                if let objects = objects {
                    println(objects)
                    for object in objects {
                        objectId = object.objectId as! String!
                        println("ObjectId: \(objectId)")
                    }
                }
            } else {
                println("No objects - Error should not occur")
            }
            
            var query2 = PFQuery(className: "request")
            let acceptedTask = query2.getObjectWithId(objectId)
            
            
            if let acceptedTask = acceptedTask {
                acceptedTask["accepted"] = "No"
                acceptedTask["acceptedBy"] = NSNull()
                acceptedTask.save()
            }
            
            self.deleteChatConnection()
            
            self.acceptedLabel.text = "None."
            self.acceptedLabel.hidden = false
            self.withdrawButton.hidden = true
            
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func deleteChatConnection() {
        var objectId = ""
        
        var query = PFQuery(className: "chat")
        query.whereKey("sender1", equalTo: fbUsername)
        query.whereKey("sender2", equalTo: name)
        
        let objects = query.findObjects()
        if objects != nil {
            if let objects = objects {
                println(objects)
                for object in objects {
                    objectId = object.objectId as! String!
                    println("ObjectId: \(objectId)")
                }
            }
        }
        
        var query2 = PFQuery(className: "chat")
        let chat = query2.getObjectWithId(objectId)
        
        if let chat = chat {
            chat.deleteInBackgroundWithBlock({ (delete, error) -> Void in
                if error != nil {
                    println("Error deleting")
                    self.addSpinner("Error withdrawing", Animated: false)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.hideSpinner()
                        self.endIgnore()
                    })
                } else {
                    println("Success deleting chat connection")
                    self.addSpinner("Done", Animated: false)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.hideSpinner()
                        self.endIgnore()
                    })
                }
            })
        }

    }
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        beginIgnore()
        addSpinner("Logging out", Animated: true)
        delay(seconds: 6.0) { () -> () in
            if tooLong == true {
                self.addSpinner("Taking longer than normal", Animated: true)
                self.delay(seconds: 6.0, completion: { () -> () in
                    self.addSpinner("Try again later", Animated: false)
                })
            }
        }
        
        if result.isCancelled {
            println("Facebook logout canceled")
            addSpinner("Logout canceled", Animated: false)
            delay(seconds: 1.0, completion: { () -> () in
                self.hideSpinner()
                tooLong = false
            })
        } else {
            
            delay(seconds: 1.0) { () -> () in
                
                if error == nil {
                    println("Login complete.")
                    
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
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User logged out...")
        
        self.navigationController?.popViewControllerAnimated(false)
        self.performSegueWithIdentifier("profileToStart", sender: self)
    }
    
    func getTask() {
        var query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                println("Error")
            } else {
                println("Objects: \(objects?.count)")
                if objects?.count == 1 {
                    self.closeRequestButton.hidden = false
                    if let objects = objects {
                        for object in objects {
                            println(object)
                            self.taskLabel.text = object["task"] as? String
                            myRequestedTask = object["task"] as! String
                            if object["accepted"] as? String == "No" {
                                println("Not accepted")
                                let pendingFiller = " - Pending"
                                self.taskLabel.text = (object["task"] as? String)! + pendingFiller
                                self.taskLabel.hidden = false
                                
                                self.taskPending = true
                            }
                            if object["accepted"] as? String == "Yes" {
                                println("Not accepted")
                                let acceptedFiller = " - Accepted"
                                self.taskLabel.text = (object["task"] as? String)! + acceptedFiller
                                self.taskLabel.hidden = false
                            }
                        }
                    }
                } else {
                    println("No requests")
                    self.taskLabel.text = "None."
                    self.taskLabel.hidden = false
                    self.closeRequestButton.hidden = true
                }
            }
        }
    }
    
    func getAccepted() {
        var query = PFQuery(className: "request")
        query.whereKey("acceptedBy", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            if error != nil {
                println("Error")
            } else {
                if let objects = objects {
                    if objects.count == 0 {
                        println("0 objects")
                        self.acceptedLabel.text = "None."
                        self.acceptedLabel.hidden = false
                        self.withdrawButton.hidden = true
                    }
                    if objects.count == 1 {
                        for object in objects {
                            println("1 object")
                            name = (object["requester"] as? String)!
                            let sFiller = "'s"
                            let requestFiller = " request for "
                            let task = object["task"] as? String
                            self.acceptedLabel.text = name + sFiller + requestFiller + task!
                            self.acceptedLabel.hidden = false
                        }
                        self.withdrawButton.titleLabel?.text = "Withdraw"
                        self.withdrawButton.hidden = false
                    } else {
                        println("Error in accepted")
                        self.acceptedLabel.text = "None."
                        self.acceptedLabel.hidden = false
                        self.withdrawButton.hidden = true
                    }
                }
            }
        }
    }
    
    func getPoints() {
        var objectId = ""
        var userPoints: Int = 0
        var updatedUserPoints: Int?
        
        var query = PFQuery(className: "points")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    println(objects)
                    for object in objects {
                        objectId = object.objectId as! String!
                        println("ObjectId: \(objectId)")
                    }
                }
                
                var query2 = PFQuery(className: "points")
                query2.getObjectInBackgroundWithId(objectId, block: { (points, error) -> Void in
                    if let points = points {
                        self.currentUserPoints = points["points"] as! Int
                        println("Points: \(userPoints)")
                    }
                    self.pointsLabel.text = "Points: \(self.currentUserPoints)"   // set label
                })
            } else {
                println("Error - User has no points class")
            }
        }
        
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
