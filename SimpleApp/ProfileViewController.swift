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

var accepted:Bool = false
var name = ""

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var taskLabel: UILabel!
    
    @IBOutlet weak var acceptedLabel: UILabel!
    
    @IBOutlet weak var withdrawButton: UIButton!
    
    @IBOutlet weak var closeRequestButton: UIButton!
    
    @IBAction func withdrawButtonPressed(sender: AnyObject) {
        var objectId = ""
        println("Withdraw")
        self.withdrawButton.enabled = false
        
        var query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: name)
        
        let objects = query.findObjects()
        
        if let objects = objects {
            println(objects)
            for object in objects {
                objectId = object["objectId"] as! String
            }
        }
        
        var query2 = PFQuery(className: "request")
        let acceptedTask = query2.getObjectWithId(objectId)
        
        println(acceptedTask)
        
        if let acceptedTask = acceptedTask {
            acceptedTask["accepted"] = "No"
            acceptedTask.save()
        }
        
        
    }
    
    @IBAction func logoutButton(sender: AnyObject) {
        FBSDKAccessToken.currentAccessToken() == nil
        self.navigationController?.popViewControllerAnimated(false)
        self.performSegueWithIdentifier("profileToStart", sender: self)
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
                    self.hideSpinner()
                    self.endIgnore()
                })
            }
        
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        withdrawButton.layer.cornerRadius = 20
        closeRequestButton.layer.cornerRadius = 20

        getTask()
        getAccepted()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                            if object["accepted"] as? String == "No" {
                                println("Not accepted")
                                let pendingFiller = " - Pending"
                                self.taskLabel.text = (object["task"] as? String)! + pendingFiller
                                self.taskLabel.hidden = false
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
                    self.taskLabel.text = "You currently do not have any requests."
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
                        self.acceptedLabel.text = "You have not accepted any tasks."
                        self.acceptedLabel.hidden = false
                        self.withdrawButton.hidden = true
                        accepted = true
                    }
                    if objects.count == 1 {
                        self.withdrawButton.hidden = false
                        for object in objects {
                            println(object)
                            name = (object["requester"] as? String)!
                            let sFiller = "'s"
                            let requestFiller = " request for "
                            let task = object["task"] as? String
                            self.acceptedLabel.text = name + sFiller + requestFiller + task!
                            self.acceptedLabel.hidden = false
                        }
                    } else {
                        println("Error")
                    }
                }
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
