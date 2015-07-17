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

    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var acceptButtonOutlet: UIButton!
    
    @IBAction func acceptButton(sender: AnyObject) {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        taskNameLabel.hidden = true
        acceptButtonOutlet.layer.cornerRadius = 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println(selectedRowText)
        
        taskNameLabel.text = selectedRowText
        taskNameLabel.hidden = false
        
        var query = PFQuery(className: "request")
        query.whereKey("task", equalTo: selectedRowText)
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]?, error) -> Void in
            tooLong = false
            if error != nil {
                println(error)
                self.addSpinner("Try again later", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    self.hideSpinner()
                })
            } else {           // **************************
                for object in objects! {
                    var label = object["requester"] as? String
                    if label == fbUsername {
                        self.nameLabel.text = "You"
                    } else {
                        self.nameLabel.text = label
                        println(label)
                    }
                }
                
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
