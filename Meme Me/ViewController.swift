//
//  ViewController.swift
//  Meme Me
//
//  Created by Khoa Vo on 9/14/15.
//  Copyright (c) 2015 AppSynth. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    // MARK: - Properties and Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topNavBar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var topTextFieldVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomTextFieldVerticalConstraint: NSLayoutConstraint!
    let topPlaceholderText:String = "TOP"
    let bottomPlaceholderText:String = "BOTTOM"
    let imageSelected:String = "com.khoavo.imageSelectedNotificationKey" // Initialize key to notify that an image has been selected
    let textEntered:String = "com.khoavo.textEnteredNotificationKey" // Initialize key to notify that the text field has been edited
    var imageExists: Bool = false
    var aspectRatioRect: CGRect = CGRectMake(0.0, 0.0, 0.0, 0.0) // Initialize an empty global CGRect that will contain the size of the user's scaled image
    var verticalSpacing: CGFloat!
    var meme = Meme()
    
    // Define text attributes
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "Impact", size: 45)!,
        NSStrokeWidthAttributeName: -3.0
    ]
    
    let labelTextAttributes = [NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 28)!,
        NSStrokeWidthAttributeName: -3.0]
    
    // MARK: - Hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
     // MARK: - View Lifecycle Methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disable camera button if source is not available, otherwise fatal exception will be thrown
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        subscribeToKeyboardNotifications()
        subscribeToTextEnteredNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
        unsubscribeToTextEnteredNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set imageView to maintain image's aspect ratio
        imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
        
        // Set buttons to be disabled initially
        shareButton.enabled = false
        cancelButton.enabled = false
        
        // Set toolbar and nav bar visibility 
        topNavBar.alpha = 0.8
        bottomToolbar.alpha = 0.8
        
        // Set text attributes and alignment
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
        hideTextFields()
        infoLabel.attributedText = NSAttributedString(string: "select an image", attributes: labelTextAttributes)
        
        // Set text field delegates
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // Add tap gestures
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        let hideShow: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "hideShowToolbars")
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(hideShow)
        
        // Set tap gesture delegates
        hideShow.delegate = self
    }
    
    // Handle text field positioning when screen orientation changes
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
         /* To make repositioning text fields animation less abrupt, hide text fields before repositioning them, 
        then show them after they've been repositioned. */
        
        hideTextFields()
        
        coordinator.animateAlongsideTransition(nil, completion: {context in
            // Only run when an image is selected, otherwise image is nil and will cause an exception
            if self.imageExists {
                self.positionTextFields()
                self.showTextFields()
            }
        })
    }
    
    // MARK: - IBActions
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        presentViewController(pickerController, animated: true, completion: nil)
        subscribeToImageSelectedNotifications()
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        presentViewController(pickerController, animated: true, completion: nil)
        subscribeToImageSelectedNotifications()
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        // Generate a memed image 
        let image = generateMemedImage()
        
        // Define an instance of the ActivityViewController and pass a memedImage as an activity item
        let shareMemeViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // Present the ActivityViewController
        presentViewController(shareMemeViewController, animated: true, completion: nil)
        
        // Save the meme
        shareMemeViewController.completionWithItemsHandler = { (activity: String?, success: Bool, items: [AnyObject]?, error: NSError?) in
            if success {
                self.saveMeme(image)
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Reset meme editor to initial conditions
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        imageExists = false
        imagePickerView.image = nil
        hideTextFields()
        topTextField.text = topPlaceholderText
        bottomTextField.text = bottomPlaceholderText
        infoLabel.hidden = false
        infoLabel.attributedText = NSAttributedString(string: "select an image", attributes: labelTextAttributes)
        shareButton.enabled = false
        cancelButton.enabled = false
    }
    
    // MARK: - Generate memedImage
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        topNavBar.hidden = true
        bottomToolbar.hidden = true
        
        // Set screenshot to image size and render image at 0.0 scale to preserve scale factor of device's screen
        UIGraphicsBeginImageContextWithOptions(aspectRatioRect.size, true, 0.0)
        let landscape = view.frame.width > view.frame.height
        if landscape {
            saveLandscapeImage()
        }
        else {
            savePortraitImage()
        }
        
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar 
        topNavBar.hidden = false
        bottomToolbar.hidden = false
        
        return memedImage
    }
    
    func savePortraitImage() {
        let saveImageRect = CGRectMake(aspectRatioRect.origin.x, -aspectRatioRect.origin.y, view.frame.width, view.frame.height)
        view.drawViewHierarchyInRect(saveImageRect, afterScreenUpdates: true)
    }
    
    func saveLandscapeImage() {
        let saveImageRect = CGRectMake(-aspectRatioRect.origin.x, aspectRatioRect.origin.y, view.frame.width, view.frame.height)
        view.drawViewHierarchyInRect(saveImageRect, afterScreenUpdates: true)
    }
    
    // MARK: - Image picker delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Conditionally unwrap dictionary key and cast to UIImage
        if let userImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = userImage
            // Post image notifications
            postImageSelectedNotification()
            imageExists = true
            
            // Show textfields and set info label text
            infoLabel.attributedText = NSAttributedString(string: "enter meme text", attributes: labelTextAttributes)
            showTextFields()
            
            positionTextFields()
        }
        dismissViewControllerAnimated(true, completion: nil)
        unsubscribeToImageSelectedNotifications()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        unsubscribeToImageSelectedNotifications()
    }
    
    // MARK: - Text field delegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        infoLabel.hidden = true
        // Hide placeholder text only if placeholder text is displayed
        if textField == topTextField && textField.text == topPlaceholderText {
            textField.text = ""
        }
        else if textField == bottomTextField && textField.text == bottomPlaceholderText {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // If textField is empty, show respective default placeholder text
        if textField.text == "" {
            if textField == topTextField {
                textField.text = topPlaceholderText
            }
            else {
                textField.text = bottomPlaceholderText
            }
        }
        postTextEnteredNotification()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Gesture recognizer delegate methods
    // Disable hide/show toolbars when user is editing to allow user to end editing by tapping outside of text field
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if topTextField.isFirstResponder() || bottomTextField.isFirstResponder() {
            return false
        }
        else {
            return true
        }
    }
    
    // MARK: - Manage Notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func subscribeToImageSelectedNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableShareButton", name: imageSelected, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableCancelButton", name: imageSelected, object: nil)
    }
    
    func unsubscribeToImageSelectedNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: imageSelected, object: nil)
    }
    
    func subscribeToTextEnteredNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enableShareButton", name: textEntered, object: nil)
    }
    
    func unsubscribeToTextEnteredNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: textEntered, object: nil)
    }
    
    // MARK: - Move view when bottom text field is first responder
    // Move frame up when keyboardWillShowNotification is received
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            UIView.animateWithDuration(0.5, animations: {
                self.view.frame.origin.y = -self.getKeyboardHeight(notification)
            })
        }
    }
    
    // Move frame back to initial position when keyboardWillHideNotification is received
    func keyboardWillHide(notification: NSNotification) {
        let initialViewRect: CGRect = CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height)
        if bottomTextField.isFirstResponder() {
            UIView.animateWithDuration(0.5, animations: {
                self.view.frame = initialViewRect
                })
        }
    }
    
    // Called by keyboardWillShow and keyboardWillHide methods when notification is received. Returns keyboard height as a CGFloat
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // MARK: - Enable share and cancel buttons
    func postImageSelectedNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(imageSelected, object: self, userInfo: nil)
    }
    
    func postTextEnteredNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(textEntered, object: self, userInfo: nil)
    }
    
    // Enable share button when meme is complete
    func enableShareButton() {
        if imageExists && topTextField.text != topPlaceholderText && bottomTextField.text != bottomPlaceholderText {
            shareButton.enabled = true
        }
    }
    
    // Enable cancel button after user selects an image
    func enableCancelButton() {
        cancelButton.enabled = true
    }
    
    // MARK: - Utilities
    // Generate meme model object
    func saveMeme(memedImage: UIImage) {
        meme.topText = topTextField.text!
        meme.bottomText = bottomTextField.text!
        meme.image = imagePickerView.image!
        meme.memedImage = memedImage
    }
    
    // Position text fields vertically within user's selected image
    func positionTextFields() {
        // Get CGRect of scaled image
        aspectRatioRect = AVMakeRectWithAspectRatioInsideRect(imagePickerView.image!.size, imagePickerView.bounds)
        
        // Calculate text field vertical spacing
        verticalSpacing = (imagePickerView.bounds.height - aspectRatioRect.size.height) / 2
        
        // Position text fields inside scaled image
        topTextFieldVerticalConstraint.constant = verticalSpacing
        bottomTextFieldVerticalConstraint.constant = verticalSpacing
    }
    
    // Close keyboard whenever user taps anywhere outside of keyboard:
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // Hide/show navbar and toolbar
    func hideShowToolbars() {
        // If toolbars are visible, hide them
        if topNavBar.alpha >= 0.8 && bottomToolbar.alpha >= 0.8 {
            UIView.animateWithDuration(0.3, animations: {
                self.topNavBar.alpha = 0
                self.bottomToolbar.alpha = 0
            })
        }
        else {
            UIView.animateWithDuration(0.3, animations: {
                self.topNavBar.alpha = 0.8
                self.bottomToolbar.alpha = 0.8
            })
        }
    }
    
    func hideTextFields() {
        UIView.animateWithDuration(0.3, animations: {
            self.topTextField.alpha = 0
            self.bottomTextField.alpha = 0
        })
    }
    
    func showTextFields() {
        UIView.animateWithDuration(0.3, animations: {
            self.topTextField.alpha = 1
            self.bottomTextField.alpha = 1
        })
    }
    
}
