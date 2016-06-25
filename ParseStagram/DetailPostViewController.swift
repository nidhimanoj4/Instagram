//
//  DetailPostViewController.swift
//  
//
//  Created by Nidhi Manoj on 6/22/16.
//
//

import UIKit
import Parse
import ParseUI

class DetailPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var photoView: PFImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentsTableView: UITableView!
    
    var post: PFObject!

    var commentsUserArray: [PFUser] = []
    var commentsCommentsTextArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        
        let caption = post["caption"] as? String
        captionLabel.text = caption
        let likesCountText = String(post["likesCount"])
        likesCountLabel.text = likesCountText + " likes"
        let timeStampLabelText = String(post["timeStamp"])
        timeStampLabel.text = timeStampLabelText ?? "time unknown"
        let authorUser = post["author"] as! PFUser
        authorLabel.text = authorUser.username ?? ""
        
        if let photoImage = post.valueForKey("media") as? PFFile {
            photoView.file = photoImage
            photoView.loadInBackground()
        }
        
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        
        updateCommentTable()
    }
    
    
    private func updateCommentTable(){
        let commentsCountText = String(post["commentsCount"])
        commentsCountLabel.text = commentsCountText + " comments"

        
        //Handle Comments table View
        let postCommentsUserArray = post.objectForKey("commentsArrayUsers") as? [PFUser]
        if let postCommentsUserArray = postCommentsUserArray {
            commentsUserArray = postCommentsUserArray
        }
        
        let postCommentsTextArray = post.valueForKey("commentsArrayComments") as? [String]
        if let postCommentsTextArray = postCommentsTextArray {
            commentsCommentsTextArray = postCommentsTextArray
        }
        
        commentsTableView.reloadData()     // Reload the tableView now that there is new data

    }

    /* Function: numberOfRowsInSection
     * This function sets the number of rows in commentsTableView
     */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsCommentsTextArray.count//commentsUserArray.count
    }
    
    /* Function: cellForRowAtIndexPath
     * This function describes how to populate a given CommentCell
     * within the commentsTableView
     */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let commentCell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentCell
        
        if( indexPath.row < commentsUserArray.count ){
            do {
                let commentUser = try (commentsUserArray[indexPath.row]).fetchIfNeeded()
                let commentUserUsername = commentUser.username
                commentCell.userLabel.text = commentUserUsername?.capitalizedString
            } catch {
                commentCell.userLabel.text = ""
            }
        }else{
            commentCell.userLabel.text = "Unknown User"
        }
        print("commentUsername is \(commentCell.userLabel.text)")
        
        let commentText = commentsCommentsTextArray[indexPath.row]
        commentCell.commentTextLabel.text = commentText
        print("commentText is \(commentText)")
        return commentCell
    }
    
    
    
    
    @IBAction func addCommentClicked(sender: AnyObject) {
        //Updates the commentsCount field of the post
        let oldCommentNum = post.valueForKey("commentsCount") as! Int
        post["commentsCount"] = oldCommentNum + 1
        
        //Updates the field "commentsArrayUsers" in the post by appending a user
        if var usersArrayForComments = post["commentsArrayUsers"] as? [PFUser] {
            usersArrayForComments.append(PFUser.currentUser()!)
            post["commentsArrayUsers"] = usersArrayForComments
        } else {
            //The commentsArrayUsers is nil so we want to initialize an array and then append the current user as the first element
            var newArrayOfUsers : [PFUser] = []
            newArrayOfUsers.append(PFUser.currentUser()!)
            post["commentsArrayUsers"] = newArrayOfUsers
        }
        
        //Update the field "commentsArrayComments" in the post by appending a comment text string
        let commentsTextArrayForComments = post["commentsArrayComments"] as? [String]
        if var commentsTextArrayForComments = commentsTextArrayForComments {
            commentsTextArrayForComments.append(commentTextField.text!)
            post["commentsArrayComments"] = commentsTextArrayForComments
        } else {
            //The commentsArrayComments is nil so we want to initialize an array and then append this text as the first element
            var newArrayOfComments : [String] = []
            newArrayOfComments.append(commentTextField.text!)
            post["commentsArrayComments"] = newArrayOfComments
        }

        //Make sure to save in background to actually save network updates to the post's fields
        post.saveInBackgroundWithBlock { (success: Bool, error: NSError?) in
            //self.viewDidLoad()
            dispatch_async(dispatch_get_main_queue()){
                self.updateCommentTable()
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
