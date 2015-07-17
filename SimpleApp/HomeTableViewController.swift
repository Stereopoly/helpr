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

var tasks = [""]
var selectedRowText = ""

class HomeTableViewController: PFQueryTableViewController {
    
    var refresher:UIRefreshControl!
    
    var viewed:Int = 1
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "request"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false     // load more... button on table view
     //   self.objectsPerPage = 5
        
    }
    
    override func queryForTable() -> PFQuery {
        
        println("queryForTable")
        
        var query = PFQuery(className: "request")
        query.whereKey("requester", notEqualTo: fbUsername)
        
        return query
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let user = FBSDKAccessToken.currentAccessToken()
        
        println(user)
        
        let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        
        request.startWithCompletionHandler {
            
            (connection, result, error) in
            
            if error != nil {
                // Some error checking here
                println("Error in user request")
            }
            else if let userData = result as? [String:AnyObject] {
                
                // Access user data
                let username = userData["name"] as? String
                println(username)
            }
        }

    
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let indexPath = tableView.indexPathForSelectedRow();
        
        println(tableView.cellForRowAtIndexPath(indexPath!))
        
        selectedRowText = tableView.cellForRowAtIndexPath(indexPath!)!.textLabel!.text!
        
        performSegueWithIdentifier("toDetail", sender: self)
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? PFTableViewCell
        
        println(object)
        
        if cell == nil {
            cell = PFTableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        
        cell?.textLabel?.text = object?["task"] as? String
        
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }

    
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
