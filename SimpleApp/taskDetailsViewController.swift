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

    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var acceptButtonOutlet: UIButton!
    
    @IBAction func acceptButton(sender: AnyObject) {
        sendPush()
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Push Notifications
    
    func sendPush() {
        addSpinner("Requesting...", Animated: true)
        ignoreInteraction()
        
        if self.nameLabel.text == "You" {
            delay(seconds: 1.0, completion: { () -> () in
                self.addSpinner("You requested this task", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    self.hideSpinner()
                    self.beginInteraction()
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
            
            let content: String = "accepted your request for "
            
            // compiles message
            let fullMessage = currUsername + hasFiller + content + taskName + helpFiller
            
            println(fullMessage)
            
            // sends push notification
            PFPush.sendPushMessageToQueryInBackground(baseQuery, withMessage: fullMessage) { (didSend, error) -> Void in
                if error != nil {
                    // freak out
                    println("error: \(error)")
                    self.addSpinner("Error", Animated: false)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.hideSpinner()
                    })
                } else {
                    // celebrate
                    println("success! didsend: \(didSend)")
                    self.addSpinner("Success - The requester has been notified", Animated: false)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.hideSpinner()
                    })
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
