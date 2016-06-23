//
//  LoggedInViewController.swift
//  ParseStagram
//
//  Created by Nidhi Manoj on 6/21/16.
//  Copyright © 2016 Nidhi Manoj. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class LoggedInViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var captionField: UITextField!
    var queryPostsLimit = 20
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    var justThisUser = true     //Dictates whether we only want to show posts from current user or all posts
    
    var posts: [PFObject] = []

    // Initialize a UIRefreshControl
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //When filling in a tableView, tell it that I am both the delegate and the dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        //Set up the refreshControl
        refreshControl.addTarget(self, action: #selector(queryPostsData), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 28)

        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        
        queryPostsData() //Get the initial query of data and save it to an array of PFObjects - posts
    }
    
    /* Function: scrollViewDidScroll
     * This function describes actions to perform when scrolling to bottom occurred. 
     */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
            
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                //So load more posts
                queryPostsLimit = queryPostsLimit + 20
                queryPostsData()
            }
        }
    }

    
    func queryPostsData() {
        //Construct a PFQuery
        let query = PFQuery(className: "Post")
        //Set up guidelines for the query
        query.orderByDescending("createdAt")
        query.includeKey("author") //Say includeKey because author is a PFUser object within the PFObject post
        query.limit = queryPostsLimit
        if (justThisUser == true) {
            query.whereKey("author", equalTo: PFUser.currentUser()!)
        }
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        //Fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (postsArray: [PFObject]?,error: NSError?) in
            if let postsArray = postsArray {
                //Save the fetched data from the query to an array of PFObjects - posts in this class LoggedInViewController
                self.posts = postsArray
                
                //Handles when we are at the bottom and want to extend for more posts
                self.isMoreDataLoading = false      //Update flag b/c we are no longer currently loading more data
                self.loadingMoreView!.stopAnimating()   //Stop the animation for the loading more Data indicator

                
                self.tableView.reloadData()     // Reload the tableView now that there is new data
                self.refreshControl.endRefreshing()      //Tell the refreshControl to stop spinning
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)

            } else {
                print("Posts query returned error")
                print(error!.localizedDescription)
            }
        }
    }
    
    

    
    /* Function: logout
     * Logout button directs user back to the loginViewController. I control+dragged from the
     * LoggedInViewController to the LoginViewController
     */
    @IBAction func logout(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) in
            //The PFUser.currentUser() is now nil
            if error == nil {
                self.performSegueWithIdentifier("logoutSegue", sender: nil) //Go back to the LoginViewController
            } else {
                print(error?.localizedDescription)
            }
        }
        print("logout has finished")

    }
    
    
    /* Function: numberOfRowsInSection
     * This function dictates the number of rows in the tableView, which is the number of posts.
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    /* Function: cellForRowAtIndexPath
     * This function sets the tableView cells. It gets a PostCell cell by calling dequeueReusableCellWithIdentifier.
     * The PostCell's properties are set by obtaining a post from the posts array (index being the current row)
     * and setting the text and values. 
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        
        let post = posts[indexPath.row]
        
        let authorUser = post.valueForKey("author") as? PFUser
        cell.authorLabel.text = authorUser?.username ?? ""
        cell.captionLabel.text = post.valueForKey("caption") as? String
        cell.likesCountLabel.text = String(post.valueForKey("likesCount")!) + " likes"
        cell.commentCountLabel.text = String(post.valueForKey("commentsCount")!) + " comments"
        
        //Use functions to set the photoView to be post.valueForKey("media") which is a PFFile
        if let photoImage = post.valueForKey("media") as? PFFile {
            cell.photoView.file = photoImage
            cell.photoView.loadInBackground()
        }
        
        //Make the profile image in the Feed's posts a circle
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height / 2
        cell.profileImage.clipsToBounds = true
        
        //Set the profileImage, which is a field (PFFile) of the PFUser
        let user = PFUser.currentUser()
        let profilePFFile = user?["profilePic"] as! PFFile
        cell.profileImage.file = profilePFFile
        cell.profileImage.loadInBackground()
        
        return cell
    }
    
    
    
    
    
    
    /* Function: uploadPostClicked
     * When the Upload Post Button is clicked, open up the Photo Library page
     */
    @IBAction func uploadPostClicked(sender: AnyObject) {
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
        
        let myResize = CGSize.init(width: 310, height: 210)
        let editedImage = Post.resize(originalImage, newSize: myResize)
        
    
        //Get Current Date
        let currentDate = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let componentsDay = calendar.components(.Day, fromDate: currentDate)
        let day = componentsDay.day
        let componentsMonth = calendar.components(.Month, fromDate: currentDate)
        let month = componentsMonth.month
        let componentsYear = calendar.components(.Year, fromDate: currentDate)
        let year = componentsYear.year
        
        let timeStampText = "\(currentDate.toShortTimeString()) \(month)/\(day)/\(year)"
        

        
      
        //Use the image - add to the posts
        Post.postUserImage(editedImage, withCaption: captionField.text, withTimeStampText: timeStampText) { (success: Bool, error: NSError?) in
            self.queryPostsData()
        }
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /* Function: prepareForSegue
     * This helps with navigation. In a storyboard-based application, you will often want to do a little
     * preparation before navigation. 
     */
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print("The segue is " + segue.identifier!)
        if (segue.identifier == "detailPostSegue") {
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
            let cell = sender as! UITableViewCell
            let indexPath = tableView.indexPathForCell(cell)
            
            let post = posts[indexPath!.row]
            let detailPostViewController = segue.destinationViewController as! DetailPostViewController
            detailPostViewController.post = post
        }
     }
    
    
}


extension NSDate {
    func toShortTimeString() -> String {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let timeString = formatter.stringFromDate(self)
        
        //Return Short Time String
        return timeString
    }
}
