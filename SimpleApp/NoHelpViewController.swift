//
//  NoHelpViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/27/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse

var sender1: String = ""
var sender2: String = ""

class NoHelpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        print("Viewwillappear - No Help")
        
        if checkForChat() {
            print("Now is in chat group")
            
            self.navigationController?.popViewControllerAnimated(false)
            
            //            self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //                println("Dismissed")
            //
            //            })
        } else {
            print("Still isn't in chat group. Stay here.")
        }
    }
    
    func checkForChat() -> Bool {       // function to check if in a chat group
        var check: Bool = false
        
        let query = PFQuery(className: "chat")
        query.whereKey("sender1", equalTo: fbUsername)
        
        let query2 = PFQuery(className: "chat")
        query2.whereKey("sender2", equalTo: fbUsername)
        
        let mergedQueries = PFQuery.orQueryWithSubqueries([query, query2])
        
        print("fbusername: " + fbUsername)
        
        var objects = [PFObject]()
        do {
            objects = try mergedQueries.findObjects()
        } catch {
            
        }
        
        print(objects)
        if objects.count == 1 {
            print("Found chat relationship")
            check = true
            
            for object in objects {
                object.setObject(sender1, forKey: "sender1")
                object.setObject(sender2, forKey: "sender2")
           //     sender1 = objects["sender1"] as! String
           //     sender2 = objects["sender2"] as! String
                print("sender1: " + sender1)
                print("sender2: " + sender2)
            }
            
            print(sender1)
            
        } else {
            print("Not in any chat group")
            check = false
        }
        
        print(check)
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
