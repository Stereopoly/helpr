//
//  addHelpableViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/15/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import Bolts
import SwiftSpinner

class addHelpableViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let pickerData = spinnerData
    var selectedRowData:String = ""
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var addButtonLabel: UIButton!
    
    @IBAction func addButton(sender: AnyObject) {
        print("Pressed request button")
        
        ignoreInteraction()
        addSpinner("Adding", Animated: true)
        
        if selectedRowData.isEmpty == true {
            self.addSpinner("Select a task", Animated: false)
            self.delay(seconds: 1.5, completion: { () -> () in
                self.hideSpinner()
                self.beginInteraction()
            })
        } else {
            
            var request = PFObject(className: "help")
            request.setObject(fbUsername, forKey: "helpr")
         //   request["helper"] = fbUsername
            request.setObject(selectedRowData, forKey: "helpable")
         //   request["helpable"] = selectedRowData
            
            var query = PFQuery(className: "help")
            query.whereKey("helpable", equalTo: selectedRowData)
            query.whereKey("helper", equalTo: fbUsername)
            
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
                                    self.addSpinner("Please try again later", Animated: false)
                                    self.delay(seconds: 1.5, completion: { () -> () in
                                        self.hideSpinner()
                                        self.beginInteraction()
                                    })
                                } else {
                                    print("Success")
                                    self.addSpinner("Success", Animated: false)
                                    self.delay(seconds: 1.5, completion: { () -> () in
                                        self.hideSpinner()
                                        self.beginInteraction()
                                    })
                                }
                            })
                            
                        })
                    } else {
                        self.delay(seconds: 1.5, completion: { () -> () in
                            self.addSpinner("Already added", Animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                self.hideSpinner()
                                self.beginInteraction()
                            })
                        })
                        
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                    self.addSpinner("Please try again later", Animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.hideSpinner()
                    })
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        addButtonLabel.layer.cornerRadius = 4
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        print(pickerData[row])
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

