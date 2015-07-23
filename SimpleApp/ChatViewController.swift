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

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var kbHeight: CGFloat!
    var messages: [PFObject]?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chatField: UITextField!

    @IBAction func sendButton(sender: AnyObject) {
        if chatField.text.isEmpty {
            println("Empty")
        } else {
            submitMessage()
        }
    }
    @IBOutlet weak var sendButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "onTimer", userInfo: nil, repeats: true)
        
        chatField.delegate = self
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.reloadData()
        
        self.tableView.registerClass(MessageViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    func submitMessage() {
        var message = PFObject(className:"Message")
        
        message["text"] = chatField.text
        chatField.text = ""
        
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
    
    func getMessages() {
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
                        self.messages?.append(object)
                    }
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
        
    }
    
    // Refresh messages
    
    func onTimer() {
        getMessages()
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MessageViewCell
        
        
        var messageText = messages![indexPath.row]
        
        cell.messageCellText.text = messageText["text"] as? String

        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        } else {
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
