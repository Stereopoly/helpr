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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
