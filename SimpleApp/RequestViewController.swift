
//
//  RequestViewController.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 7/8/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Mixpanel
import SwiftLoader

var spinnerData = ["", "ACT", "Algebra 1", "Algebra 2", "Arithimetic", "Biology", "Calculus", "Chemistry", "Chinese", "Computer Science", "English Literature", "European History", "French", "Geometry", "Grammar", "Health", "Latin", "Physics", "Pre-Algebra", "Pre-Calculus", "PSAT", "Reading Comprehension", "SAT", "Spanish", "Statistics", "Trigonometry", "U.S. History", "World History", "Writing"]

class RequestViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate {
    
    // MARK: - Variables
    
    let pickerData = spinnerData
    
    var selectedRowData:String = ""
    
    var textViewText: String = ""
    
    var placeHolderText: String = "More details can be entered here..."
    
    var kbHeight = CGFloat()
    
    var movedUp: Bool = false
    
    // MARK: - Outlets
    
    //    @IBOutlet weak var requestTextField: UITextField!
    
    //    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var requestButtonOutlet: UIButton!
    
    @IBOutlet weak var textViewOutlet: UITextView!
    
    // MARK: - Actions
    
    @IBAction func requestButton(sender: AnyObject) {
        print("Pressed request button")
        
        self.view.endEditing(true)
        
        if selectedRowData.isEmpty == true {
            SwiftLoader.show(title: "Select a task", animated: false)
            self.delay(seconds: 1.5, completion: { () -> () in
                SwiftLoader.hide()
                self.beginInteraction()
            })
        } else {
            if textViewOutlet.text.isEmpty == true {
                print("Empty textView")
                noDetailsAlert()
            }
            if textViewOutlet.text == placeHolderText {
                textViewText = ""
                print("Default placeholder text")
                noDetailsAlert()
            }
            else {
                textViewText = textViewOutlet.text
                print("Textviewtext: \(textViewText)")
                makeRequest()
            }
        }
    }
    
    func noDetailsAlert() {
        let title = "Are you sure you don't want to give any details?"
        let message = "Harder for other users to understand what you want."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Yes"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
            
            self.makeRequest()
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func subtractPoints() {
        var objectId = ""
        var userPoints: Int = 0
        var updatedUserPoints: Int?
        
        let query = PFQuery(className: "points")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error) -> Void in
            if objects != nil {
                if let objects = objects {
                    print(objects)
                    for object in objects {
                        objectId = object.objectId as String!
                        print("ObjectId: \(objectId)")
                    }
                }
                
                let query2 = PFQuery(className: "points")
                query2.getObjectInBackgroundWithId(objectId, block: { (points, error) -> Void in
                    if let points = points {
                        userPoints = points.objectForKey("points") as! Int
                        print("Points: \(userPoints)")
                        if userPoints < 1 {
                            print("Not enough points")
                            SwiftLoader.show(title: "You don't have enough points", animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                SwiftLoader.hide()
                                self.beginInteraction()
                            })
                        } else {
                            print("Enough points to request")
                            updatedUserPoints = userPoints - 1
                            print("Updated points: \(updatedUserPoints)")
                            points.setObject(updatedUserPoints!, forKey: "points")
                    //        points.objectForKey("points") = updatedUserPoints
                            
                            points.saveInBackground()
                            print("Points subtracted")
                            
                            let mixpanel: Mixpanel = Mixpanel.sharedInstance()
                            mixpanel.track("Request Made Successfully")
                            
                            print("Success")
                            SwiftLoader.show(title: "Success", animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                self.tabBarController?.selectedIndex = 0
                                SwiftLoader.hide()
                                self.beginInteraction()
                            })
                        }
                        
                    } else {
                        print("Error in points save")
                    }
                })
            } else {
                print("Error - User has no points class")
                SwiftLoader.show(title: "Error in points", animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    SwiftLoader.hide()
                    self.beginInteraction()
                })
            }
        }
        SwiftLoader.hide()
        self.beginInteraction()
    }
    
    
    
    func makeRequest() {
        self.ignoreInteraction()
        SwiftLoader.show(title: "Requsting task", animated: true)
        
        queryZipcode { () -> Void in
            
            self.checkForMultiple { () -> Void in
                
                let request = PFObject(className: "request")
                request.setObject(fbUsername, forKey: "requester")
                request.setObject(self.selectedRowData, forKey: "task")
                request.setObject(zipcode!, forKey: "zipcode")
                request.setObject("No", forKey: "accepted")
                request.setObject(self.textViewText, forKey: "details")
                
                let query = PFQuery(className: "request")
                query.whereKey("task", equalTo: self.selectedRowData)
                query.whereKey("requester", equalTo: fbUsername)
                
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        print("Successfully retrieved \(objects!.count) tasks.")
                        // Do something with the found objects
                        if objects!.count == 0 {
                            request.saveInBackgroundWithBlock({ (didWork, error) -> Void in
                                self.delay(seconds: 1.5, completion: { () -> () in
                                    print(request)
                                    if error != nil {
                                        // handle error
                                        print("Error")
                                        SwiftLoader.show(title: "Please try again later", animated: false)
                                        self.delay(seconds: 1.5, completion: { () -> () in
                                            SwiftLoader.hide()
                                            self.beginInteraction()
                                        })
                                    } else {
                                        self.subtractPoints()
                                    }
                                })
                                
                            })
                        }
                        else {
                            self.delay(seconds: 1.5, completion: { () -> () in
                                SwiftLoader.show(title: "Already requested task", animated: false)
                                self.delay(seconds: 1.5, completion: { () -> () in
                                    self.tabBarController?.selectedIndex = 0
                                    SwiftLoader.hide()
                                    self.beginInteraction()
                                })
                            })
                            
                        }
                    } else {
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                        SwiftLoader.show(title: "Please try again later", animated: false)
                        self.delay(seconds: 1.5, completion: { () -> () in
                            SwiftLoader.hide()
                        })
                    }
                }
            }
        }
    }
    
    func checkForMultiple(completion: (() -> Void) ) {
        let query = PFQuery(className: "request")
        query.whereKey("requester", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error) -> Void in
            if error == nil {
                print(objects!.count)
                if objects!.count == 0 {
                    completion()
                } else {
                    SwiftLoader.show(title: "You can only request 1 task at a time", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.tabBarController?.selectedIndex = 0
                        SwiftLoader.hide()
                        self.beginInteraction()
                    })
                }
            }
        }
        
        
    }
    
    func queryZipcode(completion: (() -> Void) ) {
        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects:[PFObject]?, error) -> Void in
            if error == nil {
                print(objects!.count)
                if objects!.count == 1 {
                    if let zip = objects?[0] {
                        zipcode = zip["zipcode"] as? Int
                        print(zipcode)
                        completion()
                    }
                } else {
                    //    SwiftSpinner.setTitleFont(UIFont(name: "System", size: 19))
                    SwiftLoader.show(title: "Error", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        SwiftLoader.hide()
                        self.beginInteraction()
                    })
                }
            }
        }
        
        
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        pickerView.delegate = self
        
        textViewOutlet.text = placeHolderText
        textViewOutlet.textColor = UIColor.lightGrayColor()
        
        textViewOutlet.delegate = self
        textViewOutlet.layer.cornerRadius = 4.0
        
        movedUp = false
    }
    
    override func viewWillAppear(animated: Bool) {
        requestButtonOutlet.layer.cornerRadius = 4
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textViewOutlet.resignFirstResponder()
            movedUp = false
            return false
        }
        
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = placeHolderText
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        self.textViewOutlet.endEditing(true)
        
        movedUp = false
        
        UIView.animateWithDuration(1.0, animations: {
            
        })
    }
    
    // MARK: - Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRowData = pickerData[row]
        print(pickerData[row])
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let myTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
    }
    
    // MARK: - Keyboard Animations
    
    func keyboardWillShow(notification: NSNotification) {
        UIView.animateWithDuration(1.0, animations: {
            
        })
        
        if movedUp == false {
            if let userInfo = notification.userInfo {
                if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                    print("Keyboard\(keyboardSize.height)")
                    kbHeight = keyboardSize.height - 95
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
        let movement = (up ? -kbHeight : kbHeight)
        
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
    
    func delay(seconds seconds: Double, completion:()->()) {
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            completion()
        }
    }
    
    
    // MARK: - Alert
    
    func displayAlertNoSegue(title: String, error: String) {
        
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
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
