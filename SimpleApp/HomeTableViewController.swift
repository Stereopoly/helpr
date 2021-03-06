//
//  HomeTableViewController.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 7/9/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import SwiftSpinner
import Mixpanel

var tasks = [""]
var selectedRowText = ""
var selectedRowDetail = ""
var fbUsername: String = ""
var zipcode: Int?
var helpable: [String] = []


class HomeTableViewController: PFQueryTableViewController {
    
    var refresher:UIRefreshControl!
    
    var viewed:Int = 1
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "request"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false     // load more... button on table view
        //   self.objectsPerPage = 5
        
    }
    
    override func queryForTable() -> PFQuery {
        
        print("queryForTable")
        
        let query = PFQuery(className: "request")
        query.whereKey("requester", notEqualTo: fbUsername)
        query.whereKey("accepted", notEqualTo: "Yes")
        if zipcode != nil {
            query.whereKey("zipcode", equalTo: zipcode!)
            print("zipcode")
        }
        if helpable.isEmpty == false {
            query.whereKey("task", containedIn: helpable)
        }
        query.orderByAscending("createdAt")
        
        return query
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        getUsername()
        
        print(fbUsername)
        
        let installation = PFInstallation.currentInstallation()
        installation.setObject(fbUsername, forKey: "user")
    //    installation["user"] = fbUsername
        installation.saveInBackground()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        getHelpable()
        
        let mixpanel: Mixpanel = Mixpanel.sharedInstance()
        mixpanel.track("View Give Screen")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUsername() {
        beginIgnore()
        
        var slow:Bool = true
        
        delay(seconds: 6.0) { () -> () in
            if slow == true {
                self.addSpinner("Taking longer than normal", Animated: true)
                self.delay(seconds: 6.0, completion: { () -> () in
                    if slow == true {
                        self.addSpinner("Try again later", Animated: false)
                        self.delay(seconds: 1.5, completion: { () -> () in
                            self.hideSpinner()
                            self.beginIgnore()
                        })
                    }
                })
            }
        }

        let query = PFQuery(className: "_User")
        query.whereKey("username", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            slow = false
            if error == nil {
                print("User count: \(objects?.count)")
                if objects!.count == 1 {
                    if let zip = objects?[0] {
                        zipcode = zip["zipcode"] as? Int
                        print(objects?[0])
                        self.getHelpable()
                        //      self.loadObjects()
                    }
                } else {
                    //    SwiftSpinner.setTitleFont(UIFont(name: "System", size: 19))
                    print("Error in query")
                }
            }
        }
        self.endIgnore()
    }
    
    
    func getHelpable() {
        let query = PFQuery(className: "help")
        query.whereKey("helper", equalTo: fbUsername)
        
        query.findObjectsInBackgroundWithBlock {
            (objects, error) -> Void in
            if error == nil {
                if let objects = objects {
                    print("Objects: \(objects)")
                    for object in objects {
                        
                        if let object = object as? PFObject {
                            helpable.append(object.objectForKey("helpable") as! String)
                        }
                    }
                }
                print("Array: \(helpable)")
                self.loadObjects()
            } else {
                print("Error: \(error)")
            }
        }
        
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow;
        
        print(tableView.cellForRowAtIndexPath(indexPath!))
        
        selectedRowText = tableView.cellForRowAtIndexPath(indexPath!)!.textLabel!.text!
        
        selectedRowDetail = tableView.cellForRowAtIndexPath(indexPath!)!.detailTextLabel!.text!
        
        performSegueWithIdentifier("toDetail", sender: self)
        
        tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        
        
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? PFTableViewCell
        
        print(object)
        
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = object?.objectForKey("task") as? String
        
        if object?.objectForKey("requester") as? String == fbUsername {
            cell?.detailTextLabel?.text = "You"
        } else {
            cell?.detailTextLabel?.text = object?.objectForKey("requester") as? String
        }
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
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
    
    func beginIgnore() {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }
    func endIgnore() {
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return NO if you do not want the item to be re-orderable.
    return true
    }
    */
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    }
    */
    
}
