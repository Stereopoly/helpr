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
import Mixpanel
import SwiftLoader

var name = ""

var myRequestedTask: String = ""

var justVerified:Bool = false

class ProfileViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var taskPending: Bool = false
    
    var currentUserPoints = 0
    
    var reloadTimer: NSTimer?
    
    var tooSlow = true
    
    
    @IBOutlet weak var acceptView: UIView!
    
    @IBOutlet weak var withdrawView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var taskLabel: UILabel!
    
    @IBOutlet weak var acceptedLabel: UILabel!
    
    @IBOutlet weak var pointsLabel: UILabel!
    
    @IBOutlet weak var withdrawButton: UIButton!
    
    @IBOutlet weak var closeRequestButton: UIButton!
    
    @IBOutlet weak var canHelpWithButton: UIButton!
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    @IBAction func closeRequestButtonPressed(sender: AnyObject) {
        if taskPending == true {
            closeRequestAlert()
            
        } else {
            self.performSegueWithIdentifier("toCloseRequest", sender: self)
        }
        
    }
    
    @IBAction func withdrawButtonPressed(sender: AnyObject) {
        print("Pressed")
        recievedAlert()
    }
    
    var slow: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delay(seconds: 10.0) { () -> () in
            if self.tooSlow == true {
                SwiftLoader.show(title: "Taking longer than normal", animated: true)
                self.delay(seconds: 6.0, completion: { () -> () in
                    SwiftLoader.show(title: "Try again later", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        SwiftLoader.hide()
                        self.endIgnore()
                    })
                })
            }
        }
        
        //        imageViewOutlet.layer.cornerRadius = self.imageViewOutlet.frame.size.height / 2
        //        imageViewOutlet.layer.masksToBounds = true
        
        //        imageViewOutlet.layer.borderWidth = 1.0
        //        imageViewOutlet.layer.masksToBounds = false
        //        imageViewOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        //        println(imageViewOutlet.frame.size.width)
        //        imageViewOutlet.layer.cornerRadius = imageViewOutlet.frame.size.height/2
        //        imageViewOutlet.clipsToBounds = true
        
        acceptView.layer.cornerRadius = 4
        withdrawView.layer.cornerRadius = 4
        canHelpWithButton.layer.cornerRadius = 4
        
        SwiftLoader.show(title: "Loading", animated: true)
        self.beginIgnore()
        
        // Do any additional setup after loading the view.
        nameLabel.hidden = true
        taskLabel.hidden = true
        acceptedLabel.hidden = true
        nameLabel.hidden = false
        
        withdrawButton.hidden = true
        closeRequestButton.hidden = true
        
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
        let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        request.startWithCompletionHandler {
            
            (connection, result, error) in
            
            if error != nil {
                // Some error checking here
                print("Error in user request")
                SwiftLoader.show(title: "Error", animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    SwiftLoader.hide()
                    self.tooSlow = false
                    self.endIgnore()
                })
            }
            else if let userData = result as? [String:AnyObject] {
                
                // Access user data
                let username = userData["name"] as? String
                let userId = userData["id"] as? String
                print("UserId: \(userId)")
                fbUsername = username!
                self.delay(seconds: 1.5, completion: { () -> () in
                    self.nameLabel.text = fbUsername
                    self.getTask()
                    self.getAccepted()
                    self.getPoints()
                    self.tooSlow = false
                    SwiftLoader.hide()
                    self.endIgnore()
                })
                
                let pictureURL = "https://graph.facebook.com/\(userId!)/picture?type=large&return_ssl_resources=1"
                
                
                let URLRequest = NSURL(string: pictureURL)
                let URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                
                NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                    if error == nil {
                        let img = UIImage(data: data!)
                        self.imageViewOutlet.image = img
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            }
            
        }
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile"]
        let size = self.view.frame.size.width - 20  as CGFloat
        let screenwidth = self.view.frame.size.width
        let screenheight = self.view.frame.height
        loginButton.frame = CGRectMake(screenwidth/2 - size/2, screenheight - 107, size, 50)
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        withdrawButton.layer.cornerRadius = 4
        closeRequestButton.layer.cornerRadius = 4
        // reloadTimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
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
        
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("View Profile Screen")
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
        let message = "Your points will be refunded."
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
            
            self.addPoints()
            
            let mixpanel: Mixpanel = Mixpanel.sharedInstance()
            mixpanel.track("User Withdrew From Task")
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func closeRequest() {
        var objectId = ""
        
        let query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        query.whereKey("task", equalTo: myRequestedTask)
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    print(objects)
                    for object in objects {
                        objectId = object.objectId as String!
                        print("ObjectId: \(objectId)")
                    }
                }
                
                let query2 = PFQuery(className: "request")
                query2.getObjectInBackgroundWithId(objectId, block: { (task, error) -> Void in
                    if let task = task {
                        task.deleteInBackgroundWithBlock({ (delete, error) -> Void in
                            if error != nil {
                                print("Error closing request")
                                SwiftLoader.show(title: "Error closing request", animated: false)
                                self.delay(seconds: 1.5, completion: { () -> () in
                                    SwiftLoader.hide()
                                    self.endIgnore()
                                })
                            } else {
                                print("Success closing request")
                                self.taskLabel.text = "None."
                                self.taskLabel.hidden = false
                                self.closeRequestButton.hidden = true
                            }
                        })
                    } else {
                        print("Error in object retrival")
                    }
                })
            } else {
                print("Error in object request")
            }
            
        }
        
    }
    
    /// Show an alert with an "Okay" and "Cancel" button.
    func recievedAlert() {
        let title = "Are you sure?"
        let message = "No shame in doing so."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Yes"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
            
            var objectId = ""
            print("Withdraw")
            self.withdrawButton.enabled = false
            
            let query = PFQuery(className: "request")
            query.whereKey("requester", equalTo: name)
            
            query.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error) -> Void in
                if error != nil {
                    print("Error")
                    SwiftLoader.show(title: "Error", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        SwiftLoader.hide()
                    })
                } else {
                    if objects != nil {
                        if let objects = objects {
                            print(objects)
                            for object in objects {
                                objectId = object.objectId as String!
                                print("ObjectId: \(objectId)")
                            }
                        }
                        let query2 = PFQuery(className: "request")
                        query2.getObjectInBackgroundWithId(objectId, block: { (acceptedTask, error) -> Void in
                            if error != nil {
                                print("Error")
                                SwiftLoader.show(title: "Error", animated: false)
                                self.delay(seconds: 1.5, completion: { () -> () in
                                    SwiftLoader.hide()
                                })
                            } else {
                                if let acceptedTask = acceptedTask {
                                    acceptedTask.setObject("No", forKey: "accepted")
                                    // acceptedTask["accepted"] = "No"
                                    acceptedTask.setObject(NSNull(), forKey: "acceptedBy")
                                    //      acceptedTask["acceptedBy"] = NSNull()
                                    acceptedTask.saveInBackground()
                                }
                                self.acceptedLabel.text = "None."
                                self.acceptedLabel.hidden = false
                                self.withdrawButton.hidden = true
                                
                                self.deleteChatConnectionNoSpinner()
                            }
                        })
                        
                    } else {
                        print("No objects - Error should not occur")
                    }
                }
            })
            
            self.endIgnore()
            
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func deleteChatConnection() {
        var objectId = ""
        
        let query = PFQuery(className: "chat")
        query.whereKey("sender1", equalTo: fbUsername)
        query.whereKey("sender2", equalTo: name)
        
        var objects = [PFObject]()
        do {
            objects = try query.findObjects()
        } catch {
            
        }
        
        print(objects)
        for object in objects {
            objectId = object.objectId as String!
            print("ObjectId: \(objectId)")
        }
        
        
        
        let query2 = PFQuery(className: "chat")
        var chat = PFObject()
        do {
            chat = try query2.getObjectWithId(objectId)
        } catch {
            
        }
        
        chat.deleteInBackgroundWithBlock({ (delete, error) -> Void in
            if error != nil {
                print("Error deleting")
                SwiftLoader.show(title: "Error withdrawing", animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    SwiftLoader.hide()
                    self.endIgnore()
                })
            } else {
                print("Success deleting chat connection")
                SwiftLoader.show(title: "Done", animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    SwiftLoader.hide()
                    self.endIgnore()
                })
            }
        })
    }
    
    func deleteChatConnectionNoSpinner() {
        var objectId = ""
        
        let query = PFQuery(className: "chat")
        query.whereKey("sender1", equalTo: fbUsername)
        query.whereKey("sender2", equalTo: name)
        
        var objects = [PFObject]()
        do {
            objects = try query.findObjects()
        } catch {
            
        }
        print(objects)
        for object in objects {
            objectId = object.objectId as String!
            print("ObjectId: \(objectId)")
        }
        
        
        
        let query2 = PFQuery(className: "chat")
        var chat = PFObject()
        do {
            chat = try query2.getObjectWithId(objectId)
        } catch {
            
        }
        chat.deleteInBackgroundWithBlock({ (delete, error) -> Void in
            if error != nil {
                print("Error deleting")
                SwiftLoader.show(title: "Error withdrawing", animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    SwiftLoader.hide()
                    self.endIgnore()
                })
            } else {
                print("Success deleting chat connection")
                self.endIgnore()
            }
        })
    }
    
    
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        beginIgnore()
        SwiftLoader.show(title: "Logging out", animated: true)
        delay(seconds: 6.0) { () -> () in
            if tooLong == true {
                SwiftLoader.show(title: "Taking longer than normal", animated: true)
                self.delay(seconds: 6.0, completion: { () -> () in
                    SwiftLoader.show(title: "Try again later", animated: false)
                })
            }
        }
        
        if result.isCancelled {
            print("Facebook logout canceled")
            SwiftLoader.show(title: "Logout canceled", animated: false)
            delay(seconds: 1.5, completion: { () -> () in
                SwiftLoader.hide()
                tooLong = false
            })
        } else {
            
            delay(seconds: 1.5) { () -> () in
                
                if error == nil {
                    print("Login complete.")
                    
                }
                else {
                    SwiftLoader.show(title: "Error in login", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        print(error.localizedDescription)
                        SwiftLoader.hide()
                    })
                    
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out...")
        
        self.navigationController?.popViewControllerAnimated(false)
        self.performSegueWithIdentifier("profileToStart", sender: self)
    }
    
    func getTask() {
        let query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error != nil {
                print("Error")
            } else {
                print("Objects: \(objects?.count)")
                if objects?.count == 1 {
                    self.closeRequestButton.hidden = false
                    if let objects = objects {
                        for object in objects {
                            print(object)
                            self.taskLabel.text = object["task"] as? String
                            myRequestedTask = object["task"] as! String
                            if object["accepted"] as? String == "No" {
                                print("Not accepted")
                                let pendingFiller = " - Pending"
                                self.taskLabel.text = (object["task"] as? String)! + pendingFiller
                                self.taskLabel.hidden = false
                                
                                self.taskPending = true
                            }
                            if object["accepted"] as? String == "Yes" {
                                print("Not accepted")
                                let acceptedBy = object["acceptedBy"] as! String
                                let acceptedFiller = " - Accepted by "
                                self.taskLabel.text = (object["task"] as? String)! + acceptedFiller + acceptedBy
                                self.taskLabel.hidden = false
                                
                                self.taskPending = false
                            }
                        }
                    }
                } else {
                    print("No requests")
                    self.taskLabel.text = "None."
                    self.taskLabel.hidden = false
                    self.closeRequestButton.hidden = true
                }
            }
        }
    }
    
    func getAccepted() {
        let query = PFQuery(className: "request")
        query.whereKey("acceptedBy", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error != nil {
                print("Error")
            } else {
                if let objects = objects {
                    if objects.count == 0 {
                        print("0 objects")
                        self.acceptedLabel.text = "None."
                        self.acceptedLabel.hidden = false
                        self.withdrawButton.hidden = true
                    }
                    if objects.count == 1 {
                        for object in objects {
                            print("1 object")
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
                        print("Error in accepted")
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
        let userPoints: Int = 0
   //     var updatedUserPoints: Int?
        
        let query = PFQuery(className: "points")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    print(objects)
                    for object in objects {
                        objectId = object.objectId as String!
                        print("ObjectId: \(objectId)")
                    }
                }
                
                let query2 = PFQuery(className: "points")
                query2.getObjectInBackgroundWithId(objectId, block: { (points, error) -> Void in
                    if let points = points {
                        //   points.setObject(self.currentUserPoints, forKey: "points")
                        self.currentUserPoints = points.objectForKey("points") as! Int
                        print("Points: \(userPoints)")
                    }
                    self.pointsLabel.text = "Points: \(self.currentUserPoints)"   // set label
                })
            } else {
                print("Error - User has no points class")
            }
        }
        
    }
    
    func addPoints() {
        
        var objectId = ""
        var userPoints: Int = 0
        var updatedUserPoints: Int?
        
        let query = PFQuery(className: "points")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    print(objects)
                    for object in objects {
                        objectId = object.objectId as String!
                        print("ObjectId: \(objectId)")
                    }
                }
                
                let query2 = PFQuery(className: "points")
                query2.getObjectInBackgroundWithId(objectId, block: { (points, error) -> Void in
                    if let points = points {
                        userPoints = points.objectForKey("points") as! Int
                        print("Points: \(userPoints)")
                        updatedUserPoints = userPoints + 1
                        print("Updated points: \(updatedUserPoints)")
                        points.setObject(updatedUserPoints!, forKey: "points")
                        //         points.objectForKey("points") = updatedUserPoints
                        
                        points.saveInBackground()
                        
                        print("Points Refunded")
                    } else {
                        print("Error in points save")
                    }
                })
            } else {
                print("Error - User has no points class")
            }
        }
        
    }
    
    // MARK: - Activity Indicator
    
    func delay(seconds seconds: Double, completion:()->()) {
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
