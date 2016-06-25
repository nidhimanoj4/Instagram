//
//  ProfileViewController.swift
//  ParseStagram
//
//  Created by Nidhi Manoj on 6/23/16.
//  Copyright © 2016 Nidhi Manoj. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePhoto: PFImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let user = PFUser.currentUser()
        usernameLabel.text = "Username: \(user!.username!)"
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height / 2
        profilePhoto.clipsToBounds = true
        
        
        let profilePFFile = user?.valueForKey("profilePic") as? PFFile
        if let profilePFFile = profilePFFile {
            profilePhoto.file = profilePFFile
            profilePhoto.loadInBackground()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /* Function: updateProfilePhoto
     * When the Update Profile Picture is clicked, open up the Photo Library page
     */

    @IBAction func updateProfilePhoto(sender: AnyObject) {
        //Set up the ImagePicker which has a didFinishPickingMediaWithInfo function, this enables selecting photos from a photo library
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        //Set up the PhotoLibrary/Camera feature
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    /* Function: didFinishPickingMediaWithInfo
     * This function uses an instantiated UIImagePickerController for the Photo Library and makes an image with
     * info. It then calls function postUserImage on the Post class with parameters as the resized image
     * and a caption. This "posts to Instagram".
     * The imagePicker for the photo Library is then dismissed.
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let myResize = CGSize.init(width: 330, height: 330)
        let editedImage = Post.resize(originalImage, newSize: myResize)
        let imagePFFile = Post.getPFFileFromImage(editedImage)
        
        
        let user = PFUser.currentUser()
        user!["profilePic"] = imagePFFile
        user?.saveInBackgroundWithBlock(nil)
        
        profilePhoto.image = editedImage

        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
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
