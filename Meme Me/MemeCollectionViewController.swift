//
//  MemeCollectionViewController.swift
//  Meme Me
//
//  Created by Khoa Vo on 10/15/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    var width: CGFloat!
    var height: CGFloat!
    var landscape = false
    
    // Get memes array from Application Delegates
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add edit button to navbar
        navigationItem.leftBarButtonItem = editButtonItem()
        
        // Set flow layout values
        let spacing: CGFloat = 4.0
        width = (view.frame.size.width - (2 * spacing)) / 3.0
        height = (view.frame.size.height - (4 * spacing)) / 5.0
        
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        
        // Set cell size if view loads when device is in landscape mode
        if view.frame.size.width > view.frame.size.height {
            landscape = true
            width = (view.frame.size.width - (4 * spacing)) / 5.0
            height = (view.frame.size.height - (2 * spacing)) / 3.0
            flowLayout.itemSize = CGSizeMake(width, height)
        }
        else {
            flowLayout.itemSize = CGSizeMake(width, height)
        }
    }
    
    // Set cell size if device orientation changes
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if width != nil && landscape {
            if UIDevice.currentDevice().orientation.isPortrait {
                flowLayout.itemSize = CGSizeMake(height, width)
            }
            else {
                flowLayout.itemSize = CGSizeMake(width, height)
            }
        }
        else if width != nil {
            if UIDevice.currentDevice().orientation.isPortrait {
                flowLayout.itemSize = CGSizeMake(width, height)
            }
            else {
                flowLayout.itemSize = CGSizeMake(height, width)
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Enable edit button if a meme exists
        navigationItem.leftBarButtonItem?.enabled = memes.count > 0
        
        collectionView?.reloadData()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        collectionView?.reloadData()
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        
        cell.memeImageView.image = meme.memedImage
        
        // Set delete button visibility and target action
        cell.deleteButton.hidden = !editing
        cell.deleteButton.addTarget(self, action: "deleteButtonPressed:", forControlEvents: .TouchUpInside)
        
        return cell
    }
    
    
    // Delete meme object from both Meme array and Collection View
    func deleteButtonPressed(sender: UIButton) {
        let cell = sender.superview!.superview! as! MemeCollectionViewCell
        let indexPath = collectionView!.indexPathForCell(cell)!
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.memes.removeAtIndex(indexPath.row)
        collectionView?.deleteItemsAtIndexPaths([indexPath])
        
        // Disable Edit button and end editing if memes array is empty
        if memes.count == 0 {
            navigationItem.leftBarButtonItem?.enabled = false
            editing = false
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let detailController = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! DetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController?.pushViewController(detailController, animated: true)
    }
    
    @IBAction func addMeme(sender: AnyObject) {
        
        let memeEditor = storyboard?.instantiateViewControllerWithIdentifier("MemeEditorViewController") as! MemeEditorViewController
        presentViewController(memeEditor, animated: true, completion: nil)
    }
    
}