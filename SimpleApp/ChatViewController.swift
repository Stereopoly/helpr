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

var didFlag = false

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var kbHeight: CGFloat!
    var messages: [PFObject]?
    var loaded = 1
    var reloadTimer: NSTimer?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageText: UITextField!
    
    @IBOutlet weak var flagButtonOutlet: UIBarButtonItem!
    
    @IBAction func flagButton(sender: AnyObject) {
        let title = "Are you sure you want to flag \(selectedChat)?"
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
            
            self.flagUser()
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    
    }
    
    @IBAction func sendButton(sender: AnyObject) {
        if messageText.text!.isEmpty {
            print("Empty")
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
        
        self.tableView.registerClass(MessageViewCell.self, forCellReuseIdentifier: "cell")
        
        self.navigationItem.title = selectedChat
        
        getMessages()
        print("Hide spinner")
        reloadTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        reloadTimer?.invalidate()
    }
    
    func flagUser() {
        var flag = PFObject(className:"flag")
        
        flag.setObject(selectedChat, forKey: "username")
      //  flag["username"] = selectedChat
        
        flag.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("User flagged successfully")
                self.navigationItem.rightBarButtonItem = nil
                didFlag = true
                
            } else {
                print("Error in flagging")
                self.ignoreInteraction()
                self.addSpinner("Error flagging", Animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    self.hideSpinner()
                    self.beginInteraction()
                })
            }
        }

    }
    
    func submitMessage() {
        var message = PFObject(className:"Message")
        
    //    message["text"] = messageText.text
        message.setObject(messageText.text!, forKey: "text")
        message.setObject(fbUsername, forKey: "sender")
        message.setObject(selectedChat, forKey: "receiver")
    //    message["sender"] =  fbUsername
    //    message["receiver"] = selectedChat
        messageText.text = ""
        
        message.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved, so get messages.
                print("Message sent")
                self.messages = []
                self.getMessages()
            } else {
                // There was a problem, check error.description
                print("could not save the message")
                print(error)
            }
        }
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
        
        if fbUsername == messageText.objectForKey("sender") as! String {
            cell.nameCellText.text = "You"
        } else {
            cell.nameCellText?.text = messageText.objectForKey("sender") as? String
        }
        
        cell.messageCellText?.text = messageText.objectForKey("text") as? String
        
        
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
            print("Selected Chat: \(selectedChat)")
            
            var query = PFQuery(className:"Message")
            query.whereKey("sender", equalTo: fbUsername)
            query.whereKey("receiver", equalTo: selectedChat)
            
            var query2 = PFQuery(className: "Message")
            query2.whereKey("sender", equalTo: selectedChat)
            query2.whereKey("receiver", equalTo: fbUsername)
            
            let comboQuery = PFQuery.orQueryWithSubqueries([query, query2])
            comboQuery.orderByAscending("createdAt")
            
            comboQuery.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                print("Messages found: \(objects?.count)")
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    if let objects = objects as [PFObject]! {
                        for object in objects {
                            
                            var indexpath = NSIndexPath(forRow: self.messages!.count, inSection: 1)
                            
                            if object.objectForKey("sender") as! String != fbUsername {
                                
                                self.messages?.append(object)
                            } else {
                                
                                self.messages?.append(object)
                            }
                        }
                        print("Count: \(self.messages?.count)")
                        self.tableView.reloadData()
                        self.tableViewScrollToBottom(true)
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                    self.addSpinner("Error", Animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.hideSpinner()
                        
                    })
                }
            }
        }
    }
    
    func tableViewScrollToBottom(animated: Bool) {
        
        let delay = 0.1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(time, dispatch_get_main_queue(), {
            
            let numberOfSections = self.tableView.numberOfSections
            let numberOfRows = self.tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
            }
            
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
        print("Viewwillappear - Chat")
        
        if didFlag == true {
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
