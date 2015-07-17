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
    
    @IBAction func addZipcode(sender: AnyObject) {
        
        var tooSlow:Bool = true
        
        ignoreInteraction()
        
        addSpinner("Hold on", Animated: true)
        
        var user = PFUser()
        user.username = fbUsername
        user.password = ""
        user["zipcode"] = zipcodeField.text.toInt()
        
        delay(seconds: 6.0) { () -> () in
            if tooSlow == true {
                self.addSpinner("Taking longer than normal", Animated: true)
                self.delay(seconds: 6.0, completion: { () -> () in
                    self.addSpinner("Try again later", Animated: false)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.hideSpinner()
                        self.beginInteraction()
                    })
                })
            }
        }
        
        user.signUpInBackgroundWithBlock { (didWork, error) -> Void in
            if error != nil {
                println("Error")
                self.addSpinner("Please try again later", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    self.hideSpinner()
                    self.beginInteraction()
                })

            } else {
                user.saveInBackgroundWithBlock({ (didWork, error) -> Void in
                    self.delay(seconds: 1.0, completion: { () -> () in
                        println(user["zipcode"])
                        if error != nil {
                            // handle error
                            println("Error")
                            self.addSpinner("Please try again later", Animated: false)
                            self.delay(seconds: 1.0, completion: { () -> () in
                                self.hideSpinner()
                                self.beginInteraction()
                                
                            })
                        } else {
                            println("Success")
                            self.addSpinner("Success", Animated: false)
                            self.delay(seconds: 1.0, completion: { () -> () in
                                self.performSegueWithIdentifier("zipcodeToTabBar", sender: self)
                                self.hideSpinner()
                                self.beginInteraction()
                            })
                        }
                    })
                })
                
            }
        }
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        tooLong = false
        
        zipcodeField.attributedPlaceholder = NSAttributedString(string: "Zipcode", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        zipcodeField.tintColor = UIColor.whiteColor()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
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
