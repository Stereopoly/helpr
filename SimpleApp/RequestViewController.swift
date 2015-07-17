
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
import SwiftSpinner

class RequestViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Variables
    
    let pickerData = ["Math", "Science", "English", "History", "Writing", "Health"]
    var selectedRowData:String = ""
    
    // MARK: - Outlets
    
//    @IBOutlet weak var requestTextField: UITextField!
    
//    @IBOutlet weak var requestLabel: UILabel!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    // MARK: - Actions
    
    @IBAction func requestButton(sender: AnyObject) {
        println("Pressed request button")
        
        ignoreInteraction()
        addSpinner("Requesting task", Animated: true)
        
        
        var request = PFObject(className: "request")
        request["requester"] = fbUsername
        request["task"] = selectedRowData
        
        var query = PFQuery(className: "request")
        query.whereKey("task", equalTo: selectedRowData)
        query.whereKey("requester", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) tasks.")
                // Do something with the found objects
                if objects!.count == 0 {
                    request.saveInBackgroundWithBlock({ (didWork, error) -> Void in
                        self.delay(seconds: 1.0, completion: { () -> () in
                            println(request)
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
                                    self.hideSpinner()
                                    self.beginInteraction()
                                })
                            }
                        })
                        
                    })
                } else {
                    self.delay(seconds: 1.0, completion: { () -> () in
                        self.addSpinner("Already requested task", Animated: false)
                        self.delay(seconds: 1.0, completion: { () -> () in
                            self.hideSpinner()
                            self.beginInteraction()
                        })
                    })
                    
                }
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
                self.addSpinner("Please try again later", Animated: false)
                self.delay(seconds: 1.0, completion: { () -> () in
                    self.hideSpinner()
                })
            }
        }
        
        
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        requestTextField.delegate = self
        //        requestTextField.tintColor = UIColor.whiteColor()
        //
        //        requestTextField.attributedPlaceholder = NSAttributedString(string: "Request", attributes: [NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        // Do any additional setup after loading the view.
        
        pickerView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    // MARK: - Picker View
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedRowData = pickerData[row]
        println(pickerData[row])
    }
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        var myTitle = NSAttributedString(string: titleData, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()])
        return myTitle
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
    
    
    // MARK: - Alert
    
    func displayAlertNoSegue(title: String, error: String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
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
