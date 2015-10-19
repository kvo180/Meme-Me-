//
//  MemeTableViewController.swift
//  Meme Me
//
//  Created by Khoa Vo on 10/15/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit

class MemeTableViewController: UITableViewController {
    
    // Get memes array from Application Delegate
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if memes.count == 0 {
            let memeEditor = storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
            presentViewController(memeEditor, animated: true, completion: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeTableViewCell") as! MemeTableViewCell
        let meme = memes[indexPath.row]
        
        cell.memeTopTextLabel.text = "\(meme.topText)..."
        cell.memeBottomTextLabel.text = meme.bottomText
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! DetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @IBAction func addMeme(sender: AnyObject) {
        
        let memeEditor = storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        presentViewController(memeEditor, animated: true, completion: nil)
    }
    
}