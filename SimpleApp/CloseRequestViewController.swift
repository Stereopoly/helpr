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

class CloseRequestViewController: UIViewController {
    
    var acceptedBy = ""

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
        
        println(myRequestedTask)
        
        addPoints()
        
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
            self.closeRequest()
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
            self.navigationController?.popViewControllerAnimated(false)
            
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
        
        var query2 = PFQuery(className: "request")
        let task = query2.getObjectWithId(objectId)
        
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
        }

        
    }
    
    
    func closeRequestWithPoints() {
        var objectId = ""
        
        var query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        query.whereKey("task", equalTo: myRequestedTask)
        query.whereKeyExists("acceptedBy")
        
        let objects = query.findObjects()
        if objects != nil {
            if let objects = objects {
                println(objects.count)
                if objects.count == 0 {
                    println("Not accepted - no help was given by anyone")
                } else {
                    for object in objects {
                        objectId = object.objectId as! String!
                        acceptedBy = object["acceptedBy"] as! String
                        println("Accepted by: \(acceptedBy)")
                        println("ObjectId: \(objectId)")
                    }
                    var query2 = PFQuery(className: "request")
                    let task = query2.getObjectWithId(objectId)
                    
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
                    }
                    
                }
            }
        }
        
    }
    
    func addPoints() {

        var objectId = ""
        var userPoints: Int = 0
        
        var query = PFQuery(className: "points")
        query.whereKey("username", equalTo: acceptedBy)
        
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
        
        var query2 = PFQuery(className: "points")
        let points = query2.getObjectWithId(objectId)
        
        if let points = points {
            userPoints = points["points"] as! Int
            println(userPoints)
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
