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

class taskDetailsViewController: UIViewController {
    
    var label = ""
    var userId: String = ""
    var accepted: String = ""
    var slow:Bool = true
    
    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var acceptButtonOutlet: UIButton!
    
    @IBAction func acceptButton(sender: AnyObject) {
        addSpinner("Requesting...", Animated: true)
        ignoreInteraction()
        
        delay(seconds: 6.0) { () -> () in
            if self.slow == true {
                self.addSpinner("Taking longer than normal", Animated: true)
                self.delay(seconds: 6.0, completion: { () -> () in
                    if self.slow == true {
                        self.addSpinner("Try again later", Animated: false)
                        self.delay(seconds: 1.0, completion: { () -> () in
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
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.accepted = object["accepted"] as! String
                        println(self.accepted)
                    }
                }
                if self.accepted == "Yes" {
                    self.addSpinner("This task has been already accepted", Animated: false)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.acceptButtonOutlet.backgroundColor = UIColor(red: 192/250, green: 57/250, blue: 43/250, alpha: 1.0)
                        self.acceptButtonOutlet.enabled = false
                        self.acceptButtonOutlet.setTitle("Accepted", forState: UIControlState.Normal)
                        self.hideSpinner()
                        self.beginInteraction()
                        self.slow = false
                    })
                } else {
                    self.sendPush()
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
                self.slow = false
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        acceptButtonOutlet.layer.cornerRadius = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(selectedRowText)
        println(selectedRowDetail)
        
        taskNameLabel.text = selectedRowText
        
        nameLabel.text = selectedRowDetail
        
        acceptButtonOutlet.setTitle("Accept", forState: UIControlState.Normal)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Push Notifications
    
    func sendPush() {
        
        if self.nameLabel.text == "You" {
            delay(seconds: 1.0, completion: { () -> () in
                self.addSpinner("You requested this task", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    self.hideSpinner()
                    self.beginInteraction()
                    self.slow = false
                })
            })
            
        } else {
            
            let baseQuery = PFInstallation.query()!
            // only ios
            baseQuery.whereKey("deviceType", equalTo: "ios")
            
            baseQuery.whereKey("username", equalTo: label)
            
            
            // compile message
            let currUsername = fbUsername
            let taskName = selectedRowText
            let hasFiller = " has "
            let helpFiller = " help."
            let talkFiller = " You may chat with him/her within the app now."
            
            let content: String = "accepted your request for "
            
            // compiles message
            let fullMessage = currUsername + hasFiller + content + taskName + helpFiller + talkFiller
            
            println(fullMessage)
            
            // sends push notification
            PFPush.sendPushMessageToQueryInBackground(baseQuery, withMessage: fullMessage) { (didSend, error) -> Void in
                if error != nil {
                    // freak out
                    println("error: \(error)")
                    self.addSpinner("Error", Animated: false)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.hideSpinner()
                        self.slow = false
                    })
                } else {
                    // celebrate
                    println("success! didsend: \(didSend)")
                    
                    var query = PFQuery(className: "request")
                    query.whereKey("requester", equalTo: selectedRowDetail)
                    
                    query.findObjectsInBackgroundWithBlock {
                        (objects: [AnyObject]?, error: NSError?) -> Void in
                        if error != nil {
                            println("Error")
                            self.addSpinner("Error", Animated: false)
                            self.delay(seconds: 1.0, completion: { () -> () in
                                self.hideSpinner()
                                self.beginInteraction()
                                self.slow = false
                            })
                        } else {
                            if objects?.count == 1 {
                                if let objects = objects as? [PFObject] {
                                    for object in objects {
                                        self.userId = object.objectId!
                                        println(self.userId)
                                    }
                                }
                                
                                var save = PFQuery(className:"request")
                                
                                save.getObjectInBackgroundWithId(self.userId) {
                                    (object: PFObject?, error: NSError?) -> Void in
                                    if error != nil {
                                        println("Error")
                                        self.addSpinner("Error", Animated: false)
                                        self.delay(seconds: 1.0, completion: { () -> () in
                                            self.hideSpinner()
                                            self.beginInteraction()
                                            self.slow = false
                                        })
                                    } else if let object = object {
                                        // Saved
                                        println(object)
                                        
                                        object["accepted"] = "Yes"
                                        
                                        object.saveInBackground()
                                        
                                        
                                        
                                        self.addSpinner("Success - The requester has been notified", Animated: false)
                                        self.delay(seconds: 1.0, completion: { () -> () in
                                            self.acceptButtonOutlet.backgroundColor = UIColor(red: 192/250, green: 57/250, blue: 43/250, alpha: 1.0)
                                            self.acceptButtonOutlet.enabled = false
                                            self.acceptButtonOutlet.setTitle("Accepted", forState: UIControlState.Normal)
                                            self.hideSpinner()
                                            self.slow = false
                                        })
                                    }
                                    
                                }
                                
                            } else {
                                println("Error")
                                self.slow = false
                            }
                        }
                    }
                    
                }
            }
        }
        beginInteraction()
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
    
    func delay(#seconds: Double, completion:()->()) {
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
