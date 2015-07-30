//
//  CloseRequestViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/30/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit

class CloseRequestViewController: UIViewController {

    @IBOutlet weak var recievedButton: UIButton!
    
    @IBOutlet weak var didNotReceiveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        recievedButton.layer.cornerRadius = 20
        didNotReceiveButton.layer.cornerRadius = 20
        
        self.title = "Close Request"
        
        if accepted == true {
            println("Accepted = true")
            recievedButton.hidden = false
            didNotReceiveButton.hidden = false
        } else {
            println("Accepted = false")
            recievedButton.hidden = true
            didNotReceiveButton.hidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
