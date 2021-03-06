
//
//  viewHelpableTableViewController.swift
//  Wanna Help
//
//  Created by Oscar Bjorkman on 7/15/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4
import SwiftSpinner

class viewHelpableTableViewController: PFQueryTableViewController {
    
    var selectedText = ""
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "help"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false     // load more... button on table view
        //   self.objectsPerPage = 5
        
    }
    
    override func queryForTable() -> PFQuery {
        
        print("queryForTableHelpable")
        
        let query = PFQuery(className: "help")
        query.whereKey("helper", equalTo: fbUsername)
        query.orderByDescending("createdAt")
        
        
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.loadObjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? PFTableViewCell
        
        //   cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        print(object)
        
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = object?.objectForKey("helpable") as? String
        
        print(cell?.textLabel?.text)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print(tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)
        selectedText = tableView.cellForRowAtIndexPath(indexPath)!.textLabel!.text!
        cancelAlert()
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    func cancelAlert() {
        let task = selectedText
        let title = "Are you sure you want to delete \(task)?"
        let message = "You will not be able to find others who want \(task) help."
        let cancelButtonTitle = "Cancel"
        let otherButtonTitle = "Yes"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("The \"Okay/Cancel\" alert's cancel action occured.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            NSLog("The \"Okay/Cancel\" alert's other action occured.")
            
            self.deleteHelpable()
            
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func deleteHelpable() {
        var objectId = ""
        
        print("Cell text: \(selectedText)")
        
        let query = PFQuery(className: "help")
        query.whereKey("helper", equalTo: fbUsername)
        query.whereKey("helpable", equalTo: selectedText)
        
        var objects = [PFObject]()
        do {
            objects = try query.findObjects()
        } catch {
            
        }
        
        print(objects)
        for object in objects {
            objectId = object.objectId as String!
            print("ObjectId: \(objectId)")
        }
    
        let query2 = PFQuery(className: "help")
        var help = PFObject(className: "help")
        do {
            help = try query2.getObjectWithId(objectId)
        } catch {
            
        }
        
        
        help.deleteInBackgroundWithBlock({ (delete, error) -> Void in
            
            if error != nil {
                print("Error deleting")
                self.addSpinner("Error withdrawing", Animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    self.hideSpinner()
                    self.endIgnore()
                })
            } else {
                print("Success deleting chat connection")
            }
        })
        
        
        self.loadObjects()
        
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell
    
    // Configure the cell...
    
    return cell
    }
    */
    
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return false
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
