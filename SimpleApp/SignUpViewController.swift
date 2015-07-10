//
//  SignUpViewController.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 6/23/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import SwiftSpinner


class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Variables
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var kbHeight: CGFloat!
    var errorMessage: String = ""
    var movedUp: Bool = false
    
    // MARK: - Outlets
    
    @IBOutlet weak var signupLabel: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var cityField: UITextField!
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    
    @IBOutlet weak var alreadyHaveAccountLabel: UILabel!
    
    @IBOutlet weak var loginButtonLabel: UIButton!
    
    @IBOutlet weak var signupButtonLabel: UIButton!
    
    // MARK: - Actions
    
    @IBAction func signupButton(sender: AnyObject) {
        
        addSpinner("Signing up", Animated: true)
        
        if usernameField.text == "" || passwordField.text == "" || confirmPasswordField.text == ""{
            if usernameField.text == "" {
                usernameLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)   // red color
            }
            if usernameField.text != "" {
                usernameLabel.backgroundColor = UIColor.whiteColor()
            }
            if passwordField.text == "" {
                passwordLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)
            }
            if passwordField.text != "" {
                passwordLabel.backgroundColor = UIColor.whiteColor()
            }
            if cityField.text == "" {
                cityLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)
            }
            if cityField.text != "" {
                cityLabel.backgroundColor = UIColor.whiteColor()
            }
            if confirmPasswordField.text == "" {
                confirmPasswordLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)
            }
            if confirmPasswordField.text != "" {
                confirmPasswordLabel.backgroundColor = UIColor.whiteColor()
            }
            
            addSpinner("Please fill out all fields ", Animated: false)
            delay(seconds: 1.0, completion: { () -> () in
                self.hideSpinner()
            })
            movedUp = false
            signupLabel.alpha = 1.0
        }
        else {
            
            if signupLogic(usernameField.text, password: passwordField.text, cpassword: confirmPasswordField.text) {
                
                var user = PFUser()
                user.username = usernameField.text
                user.password = passwordField.text
                user["City"] = cityField.text.capitalizedString
                
                println(usernameField.text)
                println(passwordField.text)
                println(cityField.text.capitalizedString)
                
                user.signUpInBackgroundWithBlock({ (success, error) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if error == nil {
                        
                        // Signup successful
                        
                        println("Signup successful")
                        
                        self.addSpinner("Success! You may now login", Animated: false)
                        self.delay(seconds: 1.0, completion: { () -> () in
                            self.performSegueWithIdentifier("toLogin", sender: self)
                        })
                        
                    }
                    else {
                        
                        if let errorString = error!.userInfo?["error"] as? String {
                            
                            var signupMessage:String = errorString
                            println(signupMessage)
                            
                        }
                        
                        self.addSpinner("Please try again later", Animated: false)
                        self.delay(seconds: 1.0, completion: { () -> () in
                            self.hideSpinner()
                        })
                        
                        println("Error in signup")
                        
                    }
                    
                })
                
                
                
            }
            else {
                addSpinner(errorMessage, Animated: false)
                delay(seconds: 1.0, completion: { () -> () in
                    self.hideSpinner()
                })
                movedUp = false
                signupLabel.alpha = 1.0
            }
        }
        
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signupLabel.alpha = 1.0
        
        usernameField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self

        usernameField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        cityField.attributedPlaceholder = NSAttributedString(string: "City", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // set cursor color
        
        usernameField.tintColor = UIColor.whiteColor()
        passwordField.tintColor = UIColor.whiteColor()
        cityField.tintColor = UIColor.whiteColor()
        confirmPasswordField.tintColor = UIColor.whiteColor()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {      // resign keyboard
        self.view.endEditing(true)
        
        movedUp = false
        
        UIView.animateWithDuration(1.0, animations: {
            
            self.signupLabel.alpha = 1.0
            
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        
        UIView.animateWithDuration(1.0, animations: {
            
            self.signupLabel.alpha = 1.0
            
            self.usernameField.alpha = 1.0
            self.usernameLabel.alpha = 1.0
            self.passwordField.alpha = 1.0
            self.passwordLabel.alpha = 1.0
            self.cityField.alpha = 1.0
            self.cityLabel.alpha = 1.0
            self.confirmPasswordField.alpha = 1.0
            self.confirmPasswordLabel.alpha = 1.0
            self.alreadyHaveAccountLabel.alpha = 1.0
            self.loginButtonLabel.alpha = 1.0
            self.signupButtonLabel.alpha = 1.0

        })

    }
    
    override func viewWillAppear(animated: Bool) {
        
        signupLabel.alpha = 0.0
        
        usernameField.alpha = 0.0
        usernameLabel.alpha = 0.0
        passwordField.alpha = 0.0
        passwordLabel.alpha = 0.0
        cityField.alpha = 0.0
        cityLabel.alpha = 0.0
        confirmPasswordField.alpha = 0.0
        confirmPasswordLabel.alpha = 0.0
        alreadyHaveAccountLabel.alpha = 0.0
        loginButtonLabel.alpha = 0.0
        signupButtonLabel.alpha = 0.0
        
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Keyboard Animations
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: {
            
            self.signupLabel.alpha = 0.0
        })
        if movedUp == false {
            if let userInfo = notification.userInfo {
                if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    kbHeight = keyboardSize.height - 120
                    movedUp = true
                    self.animateTextField(true)
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        
        UIView.animateWithDuration(0.3, animations: {
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
    // MARK: - Alert View
    
    func displayAlertWithSegue(title: String, error: String, segue: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
                self.performSegueWithIdentifier(segue, sender: self)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func displayAlertNoSegue(title: String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            

        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Activity Indicator
    
    func showActivity() {
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()

    }
    
    func endActivity() {
        
        self.activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
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
    
    // MARK: - Logic
    
    func signupLogic(username: String, password: String, cpassword: String) -> Bool {
        
        var check: Bool = false
        
        usernameLabel.backgroundColor = UIColor.whiteColor()
        passwordLabel.backgroundColor = UIColor.whiteColor()
        confirmPasswordLabel.backgroundColor = UIColor.whiteColor()
        
        if count(password) < 6 {
            println("less than 6 in password")
            passwordLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)   // red color
            errorMessage = "Password must be at least 6 characters"
            check = false
            movedUp = false
            signupLabel.alpha = 1.0
        }
        else if cpassword != password {
            println("passwords different")
            passwordLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)
            confirmPasswordLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)
            errorMessage = "Your passwords do not match"
            check = false
            movedUp = false
            signupLabel.alpha = 1.0
        }
        else {
            check = true
            usernameLabel.backgroundColor = UIColor(red: 46/250, green: 204/250, blue: 113/250, alpha: 1.0)   // green color
            passwordLabel.backgroundColor = UIColor(red: 46/250, green: 204/250, blue: 113/250, alpha: 1.0)
            confirmPasswordLabel.backgroundColor = UIColor(red: 46/250, green: 204/250, blue: 113/250, alpha: 1.0)
            movedUp = false
            signupLabel.alpha = 1.0
        }
        return check
        
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
