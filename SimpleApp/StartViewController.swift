//
//  StartViewController.swift
//  SimpleApp
//
//  Created by Oscar Bjorkman on 6/23/15.
//  Copyright (c) 2015 Oscar Bjorkman. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import ParseUI
import ParseFacebookUtilsV4
import SwiftSpinner
import SwiftLoader


var tooLong: Bool = true
var file: PFFile?

class StartViewController: UIViewController, FBSDKLoginButtonDelegate, UIPageViewControllerDataSource {
    
    var pageViewController: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!
    
    @IBOutlet weak var icon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Page view controller setup
        
        self.pageTitles = NSArray(objects: "View your current status", "Add what you can help with to get relevant requests", "View and accept requests for help made within your zipcode", "Make your own request for help", "Chat privately once matched")
        self.pageImages = NSArray(objects: "page1", "page2", "page3", "page5", "page4")
        
        self.pageViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        
        let startVC = self.viewControllerAtIndex(0) as ContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.width, self.view.frame.size.height - 120)
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMoveToParentViewController(self)
        
        // Other setup
        
        self.view.bringSubviewToFront(icon)
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile"]
        let size = 240 as CGFloat
        let screenwidth = self.view.frame.size.width
        let screenHeight = self.view.frame.size.height
        loginButton.frame = CGRectMake(screenwidth/2 - size/2, screenHeight - 70, size, 50)
        
        
        //loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Facebook Login
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        beginIgnore()
        SwiftLoader.show(title: "Logging In", animated: true)
        delay(seconds: 10.0) { () -> () in
            if tooLong == true {
                SwiftLoader.show(title: "Taking longer than normal", animated: true)
                self.delay(seconds: 10.0, completion: { () -> () in
                    SwiftLoader.show(title: "Try again later", animated: false)
                    self.delay(seconds: 2.0, completion: { () -> () in
                        SwiftLoader.hide()
                        self.endIgnore()
                    })
                })
            }
        }
        
        if result.isCancelled {
            print("Facebook login canceled")
            SwiftLoader.show(title: "Login canceled", animated: false)
            delay(seconds: 1.5, completion: { () -> () in
                SwiftLoader.hide()
                tooLong = false
            })
        } else {
            
            delay(seconds: 1.5) { () -> () in
                
                if error == nil {
                    print("Login complete.")
                    let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
                    
                    request.startWithCompletionHandler {
                        
                        (connection, result, error) in
                        
                        if error != nil {
                            // Some error checking here
                            print("Error in user request")
                            SwiftLoader.show(title: "Error", animated: false)
                            self.delay(seconds: 1.5, completion: { () -> () in
                                SwiftLoader.hide()
                                self.endIgnore()
                            })
                        }
                        else if let userData = result as? [String:AnyObject] {
                            
                            // Access user data
                            let username = userData["name"] as? String
                            let id = userData["id"] as! String
                            fbUsername = username!
                            print(username)
                            
                            let pictureURL = "https://graph.facebook.com/\(id)/picture?type=large&return_ssl_resources=1"
                            
                            let URLRequest = NSURL(string: pictureURL)
                            let URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                            
                            NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                                if error == nil {
                                    file = PFFile(name: "picture.png", data: data!)
                                }
                                else {
                                    print("Error: \(error!.localizedDescription)")
                                }
                            })
                            
                            self.checkUser()
                        }
                    }
                    
                }
                else {
                    SwiftLoader.show(title: "Error in login", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        print(error.localizedDescription)
                        SwiftLoader.hide()
                    })
                    
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out...")
    }
    
    func checkUser() {
        
        let query = PFUser.query()
        query!.whereKey("username", equalTo: fbUsername)
        
        query?.findObjectsInBackgroundWithBlock({ (objects: [PFObject]?, error) -> Void in
            tooLong = false
            if error != nil {
                print(error)
                SwiftLoader.show(title: "Try again later", animated: false)
                self.delay(seconds: 1.5, completion: { () -> () in
                    SwiftLoader.hide()
                })
            } else {
                if objects!.count == 0 {
                    SwiftLoader.show(title: "Success", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.navigationController?.popViewControllerAnimated(false)
                        self.performSegueWithIdentifier("toZipcode", sender: self)
                        SwiftLoader.hide()
                        self.endIgnore()
                        tooLong = false
                    })
                } else {
                    let query = PFQuery(className: "points")
                    query.whereKey("username", equalTo: fbUsername)
                    var objects = [PFObject]()
                    do {
                        objects = try query.findObjects()
                    } catch {
                        
                    }
                    
                    if objects.count == 1 {
                        print("Already have points row - no problem")
                    }
                    if objects.count == 0 {
                        let points = PFObject(className: "points")
                        points.setObject(fbUsername, forKey: "username")
                        // points["username"] = fbUsername
                        points.setObject(3, forKey: "points")
                        //    points["points"] = 3
                        
                        do {
                            try points.save()
                        } catch {
                            
                        }
                    } else {
                        print("Error in points class")
                    }
                    
                    SwiftLoader.show(title: "Success", animated: false)
                    self.delay(seconds: 1.5, completion: { () -> () in
                        self.navigationController?.popViewControllerAnimated(false)
                        self.performSegueWithIdentifier("toTabBarController", sender: self)
                        SwiftLoader.hide()
                        self.endIgnore()
                        tooLong = false
                    })
                }
            }
        })
        
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
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func viewControllerAtIndex(index: Int) -> ContentViewController
    {
        if ((self.pageTitles.count == 0) || (index >= self.pageTitles.count)) {
            return ContentViewController()
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
        
        
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        
        if (index == 0 || index == NSNotFound)
        {
            return nil
            
        }
        
        index--
        return self.viewControllerAtIndex(index)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound)
        {
            return nil
        }
        
        index++
        
        if (index == self.pageTitles.count)
        {
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageTitles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
}
