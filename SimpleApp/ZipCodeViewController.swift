//
//  ZipCodeViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/16/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import SwiftSpinner

class ZipCodeViewController: UIViewController {
    
    @IBOutlet weak var zipcodeField: UITextField!
    
    @IBOutlet weak var zipcodeButtonOutlet: UIButton!
    
    @IBAction func addZipcode(sender: AnyObject) {
        
        var tooSlow:Bool = true
        
        self.view.endEditing(true)
        
        ignoreInteraction()
        
        addSpinner("Hold on", Animated: true)
        
        print(zipcodeField.text)
        
        if zipcodeField.text == "" {
            addSpinner("Please enter your zipcode", Animated: false)
            delay(seconds: 1.5, completion: { () -> () in
                self.hideSpinner()
                self.beginInteraction()
            })
        } else {
            
            let user = PFUser()
            user.username = fbUsername
            user.password = ""
            user.setObject(Int(zipcodeField.text!)!, forKey: "zipcode")
            user.setObject(file!, forKey: "picture")
            //    user["zipcode"] = zipcodeField.text.toInt()
            //    user["picture"] = file
            
            delay(seconds: 6.0) { () -> () in
                if tooSlow == true {
                    self.addSpinner("Taking longer than normal", Animated: true)
                    self.delay(seconds: 6.0, completion: { () -> () in
                        self.addSpinner("Try again later", Animated: false)
                        self.delay(seconds: 1.5, completion: { () -> () in
                            self.hideSpinner()
                            self.beginInteraction()
                        })
                    })
                }
            }
            
            user.signUpInBackgroundWithBlock { (didWork, error) -> Void in
                if error != nil {
                    print("Error")
                    self.addSpinner("Please try again later", Animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.hideSpinner()
                        self.beginInteraction()
                    })
                    
                } else {
                    user.saveInBackgroundWithBlock({ (didWork, error) -> Void in
                        print(user.objectForKey("zipcode"))
                        tooSlow = false
                        print(tooSlow)
                        if error != nil {
                            // handle error
                            print("Error")
                            self.addSpinner("Please try again later", Animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                self.hideSpinner()
                                self.beginInteraction()
                                tooSlow = false
                            })
                        } else {
                            print("Success")
                            var points = PFObject(className: "points")
                            points.setObject(fbUsername, forKey: "username")
                            points.setObject(3, forKey: "points")
                            //           points["username"] = fbUsername
                            //           points["points"] = 3
                            
                            try points.save()
                            
                            self.addSpinner("Success", Animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                self.performSegueWithIdentifier("zipcodeToTabBar", sender: self)
                                self.hideSpinner()
                                self.beginInteraction()
                            })
                        }
                    })
                    
                }
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tooLong = false
        
        zipcodeButtonOutlet.layer.cornerRadius = 4.0
        
        zipcodeField.attributedPlaceholder = NSAttributedString(string: "Zipcode", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        zipcodeField.tintColor = UIColor.whiteColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
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
