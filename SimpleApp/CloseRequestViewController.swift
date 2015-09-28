//
//  CloseRequestViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/30/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import SwiftSpinner
import Mixpanel

var acceptedBy = ""

class CloseRequestViewController: UIViewController {
    
    @IBOutlet weak var recievedButton: UIButton!
    
    @IBOutlet weak var didNotReceiveButton: UIButton!
    
    @IBAction func recievedButtonPressed(sender: AnyObject) {
        recievedAlert()
    }
    
    @IBAction func didNotRecieveButtonPressed(sender: AnyObject) {
        cancelAlert()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        recievedButton.layer.cornerRadius = 4
        didNotReceiveButton.layer.cornerRadius = 4
        
        self.title = "Close Request"
        
        recievedButton.hidden = false
        didNotReceiveButton.hidden = false
        
        print(myRequestedTask)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Show an alert with an "Okay" and "Cancel" button.
    func cancelAlert() {
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
            self.closeRequestWithoutPoints()
            
            justVerified = true
            self.navigationController?.popViewControllerAnimated(false)
            
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
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
            self.closeRequestWithPoints()
            
            justVerified = true
            self.navigationController?.popViewControllerAnimated(false)
            
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func closeRequestWithoutPoints() {
        var objectId = ""
        
        let query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        query.whereKey("task", equalTo: myRequestedTask)
        query.whereKeyExists("acceptedBy")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    print(objects.count)
                    if objects.count == 0 {
                        print("Not accepted - no help was given by anyone")
                    } else {
                        for object in objects {
                            objectId = object.objectId as String!
                            acceptedBy = object["acceptedBy"] as! String
                            print("Accepted by: \(acceptedBy)")
                            print("ObjectId: \(objectId)")
                        }
                        let query2 = PFQuery(className: "request")
                        var task = PFObject()
                        do {
                            task = try query2.getObjectWithId(objectId)
                        } catch {
                            
                        }
                        
                        task.deleteInBackgroundWithBlock({ (delete, error) -> Void in
                            if error != nil {
                                print("Error closing request")
                                self.addSpinner("Error closing request", Animated: false)
                                self.delay(seconds: 1.5, completion: { () -> () in
                                    self.hideSpinner()
                                    self.endIgnore()
                                })
                            } else {
                                print("Success closing request")
                                self.deleteChatConnection()
                                self.deleteChatMessages()
                                self.refundPoints()
                                
                                justVerified = true
                                
                                let mixpanel: Mixpanel = Mixpanel.sharedInstance()
                                mixpanel.track("Request Closed", properties:["Points": false])
                                
                            }
                        })
                        
                    }
                }
            } else {
                print("Error in finding object")
            }
        }
        
    }
    
    func closeRequestWithPoints() {
        var objectId = ""
        
        let query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        query.whereKey("task", equalTo: myRequestedTask)
        query.whereKeyExists("acceptedBy")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    print(objects.count)
                    if objects.count == 0 {
                        print("Not accepted - no help was given by anyone")
                    } else {
                        for object in objects {
                            objectId = object.objectId as String!
                            acceptedBy = object["acceptedBy"] as! String
                            print("Accepted by: \(acceptedBy)")
                            print("ObjectId: \(objectId)")
                        }
                        let query2 = PFQuery(className: "request")
                        var task = PFObject()
                        do {
                            task = try query2.getObjectWithId(objectId)
                        } catch {
                            
                        }
                        
                        task.deleteInBackgroundWithBlock({ (delete, error) -> Void in
                            if error != nil {
                                print("Error closing request")
                                self.addSpinner("Error closing request", Animated: false)
                                self.delay(seconds: 1.5, completion: { () -> () in
                                    self.hideSpinner()
                                    self.endIgnore()
                                })
                            } else {
                                print("Success closing request")
                                self.deleteChatConnection()
                                self.addPoints()
                                
                                let mixpanel: Mixpanel = Mixpanel.sharedInstance()
                                mixpanel.track("Request Closed", properties:["Points": true])
                                
                            }
                        })
                        
                        
                    }
                }
            } else {
                print("Error in finding object")
            }
        }
        
    }
    
    func addPoints() {
        
        var objectId = ""
        var userPoints: Int = 0
        var updatedUserPoints: Int?
        
        let query = PFQuery(className: "points")
        query.whereKey("username", equalTo: acceptedBy)
        print("acceptedBy: \(acceptedBy)")
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
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
                        //   points["points"] = updatedUserPoints
                        
                        points.saveInBackground()
                        
                        print("Points saved")
                    } else {
                        print("Error in points save")
                    }
                })
            } else {
                print("Error - User has no points class")
            }
        }
        
    }
    
    func deleteChatConnection() {
        var objectId = ""
        
        let query = PFQuery(className: "chat")
        query.whereKey("sender1", equalTo: acceptedBy)
        query.whereKey("sender2", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    print(objects)
                    for object in objects {
                        objectId = object.objectId as String!
                        print("ObjectId: \(objectId)")
                    }
                }
            }
            
            let query2 = PFQuery(className: "chat")
            query2.getObjectInBackgroundWithId(objectId, block: { (chat, error) -> Void in
                if let chat = chat {
                    chat.deleteInBackgroundWithBlock({ (delete, error) -> Void in
                        if error != nil {
                            print("Error deleting")
                            self.addSpinner("Error closing chat", Animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                self.hideSpinner()
                            })
                        } else {
                            print("Success deleting chat connection")
                            self.deleteChatMessages()
                        }
                    })
                }
                
            })
        }
    }
    
    func deleteChatMessages() {
        var objectIds = [String]()
        
        print("Conversation: \(acceptedBy) + \(fbUsername)")
        
        let query = PFQuery(className: "Message")
        query.whereKey("sender", equalTo: acceptedBy)
        query.whereKey("receiver", equalTo: fbUsername)
        
        let query2 = PFQuery(className: "Message")
        query2.whereKey("sender", equalTo: fbUsername)
        query2.whereKey("receiver", equalTo: acceptedBy)
        
        let combinedQuery = PFQuery.orQueryWithSubqueries([query, query2])
        combinedQuery.findObjectsInBackgroundWithBlock { (messages, error) -> Void in
            if error != nil {
                print("Error in messages query")
            } else {
                print("Messages: \(messages)")
                if messages != nil {
                    if let messages = messages  {
                        for message in messages {
                            objectIds.append(message.objectId as String!)
                        }
                        print("ObjectIds: \(objectIds)")
                    }
                    //       var deleteQuery = PFQuery(className: "Messages")
                    
                    for objectId in objectIds {
                        print(objectId)
                        let delete = PFQuery(className: "Message")
                        delete.getObjectInBackgroundWithId(objectId, block: { (chatMessage, error) -> Void in
                            if let chatMessage = chatMessage {
                                chatMessage.deleteInBackgroundWithBlock({ (delete, error) -> Void in
                                    if error != nil {
                                        print("Error deleting message")
                                    } else {
                                        print("Success deleting chat message")
                                    }
                                })
                            }
                        })
                    }
                    
                }
            }
        }
        justVerified = true
    }
    
    func refundPoints() {
        
        var objectId = ""
        var userPoints: Int = 0
        var updatedUserPoints: Int?
        
        let query = PFQuery(className: "points")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
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
                        //        points.objectForKey["points"] = updatedUserPoints
                        
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


