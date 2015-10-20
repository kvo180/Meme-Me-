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
        
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Enable edit button if a meme exists
        navigationItem.leftBarButtonItem?.enabled = memes.count > 0
        
        tableView.reloadData()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
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
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.memes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    @IBAction func addMeme(sender: AnyObject) {
        
        let memeEditor = storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        presentViewController(memeEditor, animated: true, completion: nil)
    }
    
}