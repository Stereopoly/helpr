//
//  ViewController.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 6/22/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import SwiftSpinner


class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Variables
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var kbHeight: CGFloat!
    var movedUp: Bool = false
    
    // MARK: - Outlets

    @IBOutlet weak var loginLabel: UILabel!
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var noAccountLabel: UILabel!
    
    @IBOutlet weak var signupButtonOutlet: UIButton!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    // MARK: - Actions
    
    @IBAction func loginButton(sender: AnyObject) {
        
        if usernameField.text == "" || passwordField.text == "" {
            displayAlertNoSegue("Error", error: "Please fill out all fields")
            if usernameField.text == "" {
                usernameLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)  // red color
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
            movedUp = false
            loginLabel.alpha = 1.0
            
        }
        else {
            
            addSpinner("Logging In", Animated: true)
            
            PFUser.logInWithUsernameInBackground(usernameField.text, password: passwordField.text) { (user, error) -> Void in
                
                if user != nil {
                    
                    self.usernameLabel.backgroundColor = UIColor(red: 46/250, green: 204/250, blue: 113/250, alpha: 1.0)   // green color
                    self.passwordLabel.backgroundColor = UIColor(red: 46/250, green: 204/250, blue: 113/250, alpha: 1.0)
                    
                    // Logged in
                    
                    println("Logged in")
                    
                    PFUser.currentUser()!.fetch()
                    
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.addSpinner("Success", Animated: false)
                        self.delay(seconds: 1.0, completion: { () -> () in
                            self.performSegueWithIdentifier("toHome", sender: self)
                        })
                    })
                    
                }
                else {
                    
                    self.addSpinner("Check credentials", Animated: true)
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.hideSpinner()
                    })
                    self.usernameLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)
                    self.passwordLabel.backgroundColor = UIColor(red: 217/250, green: 30/250, blue: 24/250, alpha: 1.0)
                }
                
            }
            
            
        }
        
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginLabel.alpha = 1.0
        
        usernameField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        
        usernameField.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        passwordField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // set cursor color
        
        usernameField.tintColor = UIColor.whiteColor()
        passwordField.tintColor = UIColor.whiteColor()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        // text field animations
        
        UIView.animateWithDuration(1.0, animations: {
            
            self.loginLabel.alpha = 1.0
            self.loginButtonOutlet.alpha = 1.0
            
            self.noAccountLabel.alpha = 1.0
            self.signupButtonOutlet.alpha = 1.0
            
            self.usernameField.alpha = 1.0
            self.usernameLabel.alpha = 1.0
            self.passwordField.alpha = 1.0
            self.passwordLabel.alpha = 1.0
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {      // resign keyboard
        self.view.endEditing(true)
        
        movedUp = false
        
        UIView.animateWithDuration(1.0, animations: {
            
            self.loginLabel.alpha = 1.0
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func viewWillAppear(animated: Bool) {

        loginLabel.alpha = 0.0
        loginButtonOutlet.alpha = 0.0
        
        noAccountLabel.alpha = 0.0
        signupButtonOutlet.alpha = 0.0
        
        usernameField.alpha = 0.0
        usernameLabel.alpha = 0.0
        passwordField.alpha = 0.0
        passwordLabel.alpha = 0.0
        
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
            
            self.loginLabel.alpha = 0.0
        })
        if movedUp == false {
            if let userInfo = notification.userInfo {
                if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    kbHeight = keyboardSize.height - 175
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
    
    // MARK: - Alert
    
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
    
}

