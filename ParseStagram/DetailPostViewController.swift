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

class DetailPostViewController: UIViewController {

    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var photoView: PFImageView!
    
    var post: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        
        let caption = post["caption"] as? String
        captionLabel.text = caption
        
        let likesCountText = String(post["likesCount"])
        likesCountLabel.text = likesCountText + " likes"
        
        let commentsCountText = String(post["commentsCount"])
        commentsCountLabel.text = commentsCountText + " comments"
        
        let timeStampLabelText = String(post["timeStamp"])
        timeStampLabel.text = timeStampLabelText ?? "time unknown"
        
        let authorUser = post["author"] as! PFUser
        authorLabel.text = authorUser.username ?? ""
        
        if let photoImage = post.valueForKey("media") as? PFFile {
            photoView.file = photoImage
            photoView.loadInBackground()
        }
 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
