//
//  NoHelpViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/27/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse

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
        println("Viewwillappear - No Help")
        
        if checkForChat() {
            println("Now is in chat group")
            
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                println("Dismissed")
            })
        } else {
            println("Still isn't in chat group. Stay here.")
        }
    }
    
    func checkForChat() -> Bool {       // function to check if in a chat group
        var check: Bool = false
        
        var query = PFQuery(className: "chat")
        query.whereKey("sender1", equalTo: fbUsername)
        query.whereKey("sender2", equalTo: fbUsername)
        
        println("fbusername: " + fbUsername)
        
        let objects = query.findObjects()
        
        println(objects)
        if objects?.count == 1 {
            println("Found chat relationship")
            check = true
        } else {
            println("Not in any chat group")
            check = false
        }
        
        println(check)
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
