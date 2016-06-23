//
//  AppDelegate.swift
//  ParseStagram
//
//  Created by Nidhi Manoj on 6/20/16.
//  Copyright © 2016 Nidhi Manoj. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Initialize Parse
        // Set applicationId and server based on the values in the Heroku settings.
        // clientKey is not used on Parse open source unless explicitly configured
        Parse.initializeWithConfiguration(
            ParseClientConfiguration(block: { (configuration:ParseMutableClientConfiguration) -> Void in
                configuration.applicationId = "parse-stagram"
                configuration.clientKey = "blob"  // set to nil assuming you have not set clientKey
                configuration.server = "https://parse-stagram.herokuapp.com/parse"
            })
        )

        
        
        //check if a user is logged in, in which case skip loginViewController and set initial rootViewController to be the loggedInViewController page
        if PFUser.currentUser() == nil {
            //set initial View controller to be the loggedInViewController
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("loginScreen") as UIViewController
            
            self.window?.rootViewController = loginViewController
        }
        
        
        
 /*
        
        //check if a user is logged in, in which case skip loginViewController and set initial rootViewController to be the loggedInViewController page
        if PFUser.currentUser() != nil {
            //set initial View controller to be the loggedInViewController
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loggedInViewController:UIViewController = storyboard.instantiateViewControllerWithIdentifier("loggedInScreen") as UIViewController

            self.window?.rootViewController = loggedInViewController
        }
*/
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

