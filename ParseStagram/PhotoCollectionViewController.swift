//
//  PhotoCollectionViewController.swift
//  ParseStagram
//
//  Created by Nidhi Manoj on 6/24/16.
//  Copyright © 2016 Nidhi Manoj. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class PhotoCollectionViewController: UIViewController, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    var posts: [PFObject] = []
    var numPhotosToShow = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        
        //This will populate the posts array by accessing the query and will reload the data
        queryPostsData()
    }
    
    
    
    
    func queryPostsData() {
        //Construct a PFQuery
        let query = PFQuery(className: "Post")
        //Set up guidelines for the query
        query.orderByDescending("createdAt")
        query.includeKey("author") //Say includeKey because author is a PFUser object within the PFObject post
        query.limit = numPhotosToShow
        query.whereKey("author", equalTo: PFUser.currentUser()!)
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        //Fetch data asynchronously
        query.findObjectsInBackgroundWithBlock { (postsArray: [PFObject]?,error: NSError?) in
            if let postsArray = postsArray {
                //Save the fetched data from the query to an array of PFObjects - posts in this class LoggedInViewController
                self.posts = postsArray
                
                
                self.collectionView.reloadData()     // Reload the tableView now that there is new data
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
            } else {
                print("Posts query returned error")
                print(error!.localizedDescription)
            }
        }
    }
    
    
    
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionViewCell", forIndexPath: indexPath) as! CollectionViewCell
        
        let post = posts[indexPath.row]
        
        //Use functions to set the photoView to be post.valueForKey("media") which is a PFFile
        if let photoImage = post.valueForKey("media") as? PFFile {
            cell.photoView.file = photoImage
            cell.photoView.loadInBackground()
        }
        
        //Make the profile image in the Feed's posts a circle
        //cell.photoView.layer.cornerRadius = cell.photoView.frame.height / 2
        //cell.photoView.clipsToBounds = true

        
        return cell
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
        if (segue.identifier == "detailPostSegueFromCollection") {
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
            let cell = sender as! UICollectionViewCell
            let indexPath = collectionView.indexPathForCell(cell)
            
            let post = posts[indexPath!.row]
            let detailPostViewController = segue.destinationViewController as! DetailPostViewController
            detailPostViewController.post = post
        }
    }

    
    
    
}
