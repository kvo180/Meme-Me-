//
//  DetailViewController.swift
//  Meme Me
//
//  Created by Khoa Vo on 10/17/15.
//  Copyright © 2015 AppSynth. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var meme: Meme!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add tap gestures to hide/show navbars
        let hideShow: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideShowToolbars")
        view.addGestureRecognizer(hideShow)
        hideShow.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.image = meme.memedImage
    }
    
    // Hide/show navbars
    func hideShowToolbars() {
        // If toolbars are visible, hide them
        let navBar = navigationController?.navigationBar
        let tabBar = tabBarController?.tabBar
        if navBar?.alpha >= 0.8 && tabBar?.alpha >= 0.8 {
            UIView.animateWithDuration(0.3, animations: {
                navBar?.alpha = 0
                tabBar?.alpha = 0
            })
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                navBar?.alpha = 0.8
                tabBar?.alpha = 0.8
            })
        }
    }
}
