//
//  MemeCollectionViewController.swift
//  Meme Me
//
//  Created by Khoa Vo on 10/15/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UICollectionViewController {
    
    // Get memes array from Application Delegates
    var memes: [Meme] {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).memes
    }
}
