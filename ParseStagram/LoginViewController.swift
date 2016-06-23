//
//  LoginViewController.swift
//  ParseStagram
//
//  Created by Nidhi Manoj on 6/20/16.
//  Copyright © 2016 Nidhi Manoj. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onSignIn(sender: AnyObject) {
        let usernameText = usernameField.text ?? ""
        let passwordText = passwordField.text ?? ""
        
        //This function returns  an instance of successfully logged in PFUser
        //PFUser.currentUser() is the last logged in user
        PFUser.logInWithUsernameInBackground(usernameText, password: passwordText) { (user: PFUser?,error: NSError?) -> Void in
            if let error = error {             // check if error != nil and unwrap
                // error in login failed
                print("User login failed")
                self.alertForError(error)
            } else {
                print("You are logged in")
                self.performSegueWithIdentifier("loginSegue", sender: nil) //Go to the loggedInViewController page
            }
        }
    }
    
    @IBAction func onSignUp(sender: AnyObject) {
        // initialize a user object
        let newUser = PFUser()
        
        // set user properties
        newUser.username = usernameField.text
        newUser.password = passwordField.text
        
        newUser.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("Yay created a new user")
                self.performSegueWithIdentifier("loginSegue", sender: nil) //Go to the loggedInViewController page
            } else {
                print("Could not sign up this new user")
                self.alertForError(error!)
            }
        }
    }
    
    func alertForError(error: NSError) -> Void {
        let message = error.localizedDescription
        let title = "Error: " + String(error.code)
        let alertController = UIAlertController(title: title, message: message.capitalizedString, preferredStyle: .Alert)
        
        //Create an OK action
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        
        //Add OK action to the alert controller
        alertController.addAction(OKAction)
        
        presentViewController(alertController, animated: true) { 
            //optional code on what happends after Alert Controller has finished presenting
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
