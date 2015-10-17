//
//  DetailViewController.swift
//  Meme Me
//
//  Created by Khoa Vo on 10/17/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = meme.memedImage
    }
}
