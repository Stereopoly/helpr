
//
//  taskDetailsViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/17/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import SwiftSpinner
import FBSDKCoreKit
import FBSDKLoginKit
import ParseUI
import ParseFacebookUtilsV4
import SwiftSpinner
import Mixpanel

var acceptedTask: String = ""

class taskDetailsViewController: UIViewController {
    
    var userId: String = ""
    var accepted: String = ""
    var slow:Bool = true
    
    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var acceptButtonOutlet: UIButton!
    
    @IBOutlet weak var textViewOutlet: UITextView!
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    
    @IBAction func acceptButton(sender: AnyObject) {
        ignoreInteraction()
        
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

        addSpinner("Accepting...", Animated: true)
        
        delay(seconds: 10.0) { () -> () in
            if self.slow == true {
                self.addSpinner("Taking longer than normal", Animated: true)
                self.delay(seconds: 6.0, completion: { () -> () in
                    if self.slow == true {
                        self.addSpinner("Try again later", Animated: false)
                        self.delay(seconds: 1.5, completion: { () -> () in
                            self.hideSpinner()
                            self.beginInteraction()
                        })
                    }
                })
            }
        }
        
        var query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: selectedRowDetail)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) objects.")
                // Do something with the found objects
                if let objects = objects as [PFObject]! {
                    for object in objects {
                        self.accepted = object.objectForKey("accepted") as! String
                        print("Self.accepted: " + self.accepted)
                    }
                }
                if self.accepted == "Yes" {
                    self.addSpinner("This task has been already accepted", Animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.acceptButtonOutlet.backgroundColor = UIColor(red: 192/250, green: 57/250, blue: 43/250, alpha: 1.5)
                        self.acceptButtonOutlet.enabled = false
                        self.acceptButtonOutlet.setTitle("Accepted", forState: UIControlState.Normal)
                        self.hideSpinner()
                        self.beginInteraction()
                        self.slow = false
                    })
                    self.beginInteraction()
                } else {
                    self.alreadyAccepted()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                self.slow = false
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        acceptButtonOutlet.layer.cornerRadius = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        textViewOutlet.editable = false
        
        getDetails()
        getProfilePicture()
        
        print(selectedRowText)
        print(selectedRowDetail)
        
        taskNameLabel.text = selectedRowText
        
        nameLabel.text = selectedRowDetail
        
        acceptButtonOutlet.setTitle("Accept", forState: UIControlState.Normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alreadyAccepted() {
        
        let query = PFQuery(className: "request")
        query.whereKey("acceptedBy", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (accepted:[PFObject]?, error) -> Void in
            if error != nil {
                print("Error")
            } else {
                if let accepted = accepted {
                    print("Count of alreadyAccepted: \(accepted.count)")
                    if accepted.count == 1 {
                        self.slow = false
                        self.addSpinner("You cannot accept more than 1 request", Animated: false)
                        self.delay(seconds: 1.5, completion: { () -> () in
                            self.hideSpinner()
                            self.beginInteraction()
                        })
                        self.beginInteraction()
                    }
                    else if accepted.count == 0 {
                        self.sendPush()
                    } else {
                        self.slow = false
                        print("Error in count")
                        self.addSpinner("Error", Animated: false)
                        self.delay(seconds: 1.5, completion: { () -> () in
                            self.hideSpinner()
                            self.beginInteraction()
                        })
                    }
                }
            }
        }
    }
    
    // MARK: - Push Notifications
    
    func sendPush() {
        
        if self.nameLabel.text == "You" {
            delay(seconds: 1.5, completion: { () -> () in
                self.addSpinner("Error - You requested this task", Animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    self.hideSpinner()
                    self.beginInteraction()
                    self.slow = false
                })
            })
            
        } else {
            
            let baseQuery = PFInstallation.query()!
            // only ios
            baseQuery.whereKey("deviceType", equalTo: "ios")
            
            baseQuery.whereKey("user", equalTo: selectedRowDetail)
            
            acceptedTask = selectedRowText
            
            // compile message
            let currUsername = fbUsername
            let taskName = selectedRowText
            let hasFiller = " has "
            let helpFiller = " help."
            let talkFiller = " You may chat with him/her within the app now."
            
            let content: String = "accepted your request for "
            
            // compiles message
            let fullMessage = currUsername + hasFiller + content + taskName + helpFiller + talkFiller
            
            print("Fullmessage: " + fullMessage)
            
            // sends push notification
            PFPush.sendPushMessageToQueryInBackground(baseQuery, withMessage: fullMessage) { (didSend, error) -> Void in
                if error != nil {
                    // freak out
                    print("error: \(error)")
                    self.addSpinner("Error", Animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.hideSpinner()
                        self.slow = false
                        self.beginInteraction()
                    })
                } else {
                    // celebrate
                    print("success! didsend: \(didSend)")
                    
                    let query = PFQuery(className: "request")
                    query.whereKey("requester", equalTo: selectedRowDetail)
                    
                    query.findObjectsInBackgroundWithBlock {
                        (objects: [PFObject]?, error: NSError?) -> Void in
                        if error != nil {
                            print("Error")
                            self.addSpinner("Error", Animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                self.hideSpinner()
                                self.beginInteraction()
                                self.slow = false
                            })
                        } else {
                            if objects?.count == 1 {
                                if let objects = objects as [PFObject]! {
                                    for object in objects {
                                        self.userId = object.objectId!
                                        print(self.userId)
                                    }
                                }
                                
                                let save = PFQuery(className:"request")
                                
                                save.getObjectInBackgroundWithId(self.userId) {
                                    (object: PFObject?, error: NSError?) -> Void in
                                    if error != nil {
                                        print("Error")
                                        self.addSpinner("Error", Animated: false)
                                        self.delay(seconds: 1.5, completion: { () -> () in
                                            self.hideSpinner()
                                            self.beginInteraction()
                                            self.slow = false
                                        })
                                    } else if let object = object {
                                        // Saved
                                        print(object)
                                        
                                        object.setObject("Yes", forKey: "accepted")
                                        object.setObject(fbUsername, forKey: "acceptedBy")
                                  //      object["accepted"] = "Yes"
                                  //      object["acceptedBy"] = fbUsername
                                        
                                        object.saveInBackground()
                                        
                                        let chatSave = PFObject(className: "chat")
                                        chatSave.setObject(fbUsername, forKey: "sender1")
                                        chatSave.setObject(selectedRowDetail, forKey: "sender2")
                                  //      chatSave["sender1"] = fbUsername
                                  //      chatSave["sender2"] = selectedRowDetail
                                        
                                        chatSave.saveInBackgroundWithBlock({ (didWork, error) -> Void in
                                            if error != nil {
                                                print("Error")
                                                self.addSpinner("Error", Animated: false)
                                                self.delay(seconds: 1.5, completion: { () -> () in
                                                    self.hideSpinner()
                                                    self.beginInteraction()
                                                    self.slow = false
                                                })
                                            } else {
                                                self.addSpinner("Success - The requester has been notified", Animated: false)
                                                self.delay(seconds: 1.5, completion: { () -> () in
                                                    self.acceptButtonOutlet.backgroundColor = UIColor(red: 192/250, green: 57/250, blue: 43/250, alpha: 1.5)
                                                    self.acceptButtonOutlet.enabled = false
                                                    self.acceptButtonOutlet.setTitle("Accepted", forState: UIControlState.Normal)
                                                    self.navigationController?.popViewControllerAnimated(false)
                                                    self.hideSpinner()
                                                    self.slow = false
                                                    self.beginInteraction()
                                                })
                                            }
                                        })
                                        
                                    }
                                    
                                }
                                
                            } else {
                                print("Error")
                                self.slow = false
                                self.beginInteraction()
                            }
                        }
                    }
                    
                }
            }
        }
        beginInteraction()
    }
    
    func getDetails() {
        let query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: selectedRowDetail)
        query.whereKey("task", equalTo: selectedRowText)
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error) -> Void in
            if error != nil {
                print("Error in details query", terminator: "")
            } else {
                if let objects = objects {
                    for object in objects {
                        print(object["details"] as! String)
                        self.textViewOutlet.text = object["details"] as! String
                    }
                }
            }
        }
    }
    
    func getProfilePicture() {
        let userQuery = PFUser.query()
        userQuery?.whereKey("username", equalTo: selectedRowDetail)

        userQuery?.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error) -> Void in
            if error != nil {
                print("Error getting profile picture", terminator: "")
                self.addSpinner("Error getting profile picture", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    self.hideSpinner()
                    self.beginInteraction()
                })
            } else {
                if let objects = objects {
                    print(objects)
                    for object in objects {
                        let thumbNail = object["picture"] as! PFFile
                        
                        print(thumbNail)
                        
                        thumbNail.getDataInBackgroundWithBlock({
                            (imageData, error) -> Void in
                            if (error == nil) {
                                let image = UIImage(data:imageData!)
                                //image object implementation
                                self.imageViewOutlet.image = image
                            }
                            
                        })
                    }
                }
            }
        })
    }
    
    // MARK: - User interaction control
    
    func ignoreInteraction() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    
    func beginInteraction() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    // MARK: - Activity Indicator
    
    func addSpinner(Error: String, Animated: Bool) {
        SwiftSpinner.show(Error, animated: Animated)
    }
    
    func hideSpinner() {
        SwiftSpinner.hide()
    }
    
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
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
