//
//  ChatViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/22/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import SwiftSpinner

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var kbHeight: CGFloat!
    var messages: [PFObject]?
    var loaded = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageText: UITextField!
    
    @IBAction func sendButton(sender: AnyObject) {
        if messageText.text.isEmpty {
            println("Empty")
        } else {
            self.view.endEditing(true)
            submitMessage()
        }
    }
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.messageText.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
        
        self.tableView.registerClass(MessageViewCell.self, forCellReuseIdentifier: "cell")
        
        if checkForChat() {
            getMessages()
            NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        } else {
            // segue away
            println("Segue away")
            self.performSegueWithIdentifier("toNoChat", sender: self)
            self.navigationController?.popViewControllerAnimated(false)
            
        }
        
    }
    
    func submitMessage() {
        var message = PFObject(className:"Message")
        
        message["text"] = messageText.text
        message["sender"] =  fbUsername
        messageText.text = ""
        
        message.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved, so get messages.
                self.getMessages()
            } else {
                // There was a problem, check error.description
                println("could not save the message")
                println(error)
            }
        }
    }
    
    func checkForChat() -> Bool {       // function to check if in a chat group
        var check: Bool = false
        
        var query = PFQuery(className: "chat")
        query.whereKey("sender1", equalTo: fbUsername)
        
        var query2 = PFQuery(className: "chat")
        query2.whereKey("sender2", equalTo: fbUsername)
        
        let mergedQueries = PFQuery.orQueryWithSubqueries([query, query2])
        
        println("fbusername: " + fbUsername)
        
        let objects = mergedQueries.findObjects()
        
        println(objects)
        if objects?.count == 1 {
            println("Found chat relationship")
            check = true
        } else {
            println("Not in any chat group")
            check = false
        }
        
        println(check)
        return check
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        } else {
            return 0
        }
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageViewCell", forIndexPath: indexPath) as! MessageViewCell

        var messageText = messages![indexPath.row]
   //     cell.messageCellText.text = messageText["text"] as? String
        
        if fbUsername == messageText["sender"] as! String {
            cell.nameCellText.text = "You"
        } else {
            cell.nameCellText?.text = messageText["sender"] as? String
        }
        
        cell.messageCellText?.text = messageText["text"] as? String
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func onTimer() {
        getMessages()
    }
    
    func getMessages() {
        if loaded == 1 {
            self.messages = []
            var query = PFQuery(className:"Message")
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            
                            var indexpath = NSIndexPath(forRow: self.messages!.count, inSection: 1)
                            
                            if object["sender"] as! String != fbUsername {
                                
                                self.messages?.append(object)
                            } else {
                                
                                self.messages?.append(object)
                            }
                        }
                        self.tableView.reloadData()
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        } else {
            loaded = 1
            self.messages = []
            var query = PFQuery(className:"Message")
            query.orderByDescending("createdAt")
            query.findObjectsInBackgroundWithBlock {
                (objects: [AnyObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            
                            var indexpath = NSIndexPath(forRow: self.messages!.count, inSection: 1)
                            
                            if object["sender"] as! String != fbUsername {
                                self.addSpinner("Done", Animated: false)
                                self.messages?.append(object)
                            } else {
                                self.addSpinner("Done", Animated: false)
                                self.messages?.append(object)
                            }
                        }
                        self.delay(seconds: 1.0, completion: { () -> () in
                            self.tableView.reloadData()
                            self.hideSpinner()
                            self.beginInteraction()

                        })
                    }
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        println("Viewwillappear - Chat")
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? (-kbHeight + 45) : (kbHeight - 45))
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
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
