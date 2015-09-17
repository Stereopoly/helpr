//
//  ChangeZipcodeViewController.swift
//  helpr
//
//  Created by Oscar Bjorkman on 8/14/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import ParseFacebookUtilsV4
import SwiftSpinner
import Mixpanel
import FBSDKCoreKit
import FBSDKLoginKit


class ChangeZipcodeViewController: UIViewController {

    @IBOutlet weak var zipcodeOutlet: UILabel!
    
    @IBOutlet weak var zipcodeTextField: UITextField!
    
    @IBOutlet weak var changeButtonOutlet: UIButton!
    
    @IBAction func changeZipcode(sender: AnyObject) {
        self.beginIgnore()
        if zipcodeTextField.text.isEmpty == true {
            self.addSpinner("Enter a zipcode", Animated: false)
            self.delay(seconds: 1.5, completion: { () -> () in
                self.hideSpinner()
                self.endIgnore()
            })
        } else {
            changeZipcode()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        changeButtonOutlet.layer.cornerRadius = 4.0
        zipcodeTextField.attributedPlaceholder = NSAttributedString(string: "Zipcode", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        zipcodeTextField.tintColor = UIColor.whiteColor()
        
        getZipcode()
    
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getZipcode() {
        var query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                println("User count: \(objects?.count)")
                if objects!.count == 1 {
                    if let zip: AnyObject = objects?[0] {
                        zipcode = zip["zipcode"] as? Int
                        
                        self.zipcodeOutlet.text = String(stringInterpolationSegment: zipcode!)
                        println("Zipcode \(self.zipcodeOutlet.text)")
                    }
                } else {
                    println("Error in query")
                }
            }
        }

    }
    
    func changeZipcode() {
        var objectId = ""
        self.view.endEditing(true)

        var query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
            if error != nil {
                println("Error")
                self.addSpinner("Error", Animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    self.hideSpinner()
                    self.endIgnore()
                })
            } else {
                if objects != nil {
                    if let objects = objects {
                        println(objects)
                        for object in objects {
                            objectId = object.objectId as String!
                            println("ObjectId: \(objectId)")
                        }
                    }
                    var query2 = PFQuery(className: "_User")
                    
                    println("Current user:\(PFUser.currentUser()?.username)")
                    
                    query2.getObjectInBackgroundWithId(objectId, block: { (oldZipcode, error) -> Void in
                        if error != nil {
                            println("Error")
                            self.addSpinner("Error", Animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                self.hideSpinner()
                            })
                        } else if let oldZipcode = oldZipcode {
                            println("User: \(oldZipcode)")
                            var newZipcode: AnyObject? = oldZipcode.objectForKey("zipcode")
                            oldZipcode.setObject(newZipcode!, forKey: "zipcode")
                         //   oldZipcode["zipcode"] = newZipcode
                            print("New zipcode: \(newZipcode)")
                            self.zipcodeTextField.text = ""
                            oldZipcode.saveInBackground()
                            self.endIgnore()
                        }
                    })
                    
                } else {
                    println("No objects - Error should not occur")
                    self.endIgnore()
                }
            }
        })

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
