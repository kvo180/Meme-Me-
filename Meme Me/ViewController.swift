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
    let imageSelected:String = "com.khoavo.imageSelectedNotificationKey"
    let textEntered:String = "com.khoavo.textEnteredNotificationKey"
    let orientation: UIDeviceOrientation = UIDevice.currentDevice().orientation
    
    // MARK: - Hide the status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
     // MARK: - View Lifecycle Methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Disable camera button if source is not available, otherwise fatal exception will be thrown
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        self.subscribeToKeyboardNotifications()
        self.subscribeToTextEnteredNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeToKeyboardNotifications()
        self.unsubscribeToTextEnteredNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Format image to maintain aspect ratio
        imagePickerView.contentMode = UIViewContentMode.ScaleAspectFit
        
        // Set buttons to be disabled initially
        shareButton.enabled = false
        cancelButton.enabled = false
        
        // Define text attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3.0
        ]
        
        // Set text attributes and alignment
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
        hideTextFields()
        
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
    
    // MARK: - IBActions
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickerController, animated: true, completion: nil)
        subscribeToImageSelectedNotifications()
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(pickerController, animated: true, completion: nil)
        subscribeToImageSelectedNotifications()
    }
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        // Generate a memed image 
        let image = generateMemedImage()
        
        // Define an instance of the ActivityViewController and pass a memedImage as an activity item
        let shareMemeViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        // Present the ActivityViewController
        self.presentViewController(shareMemeViewController, animated: true, completion: nil)
    }
    
    // Reset meme editor to initial conditions
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        imagePickerView.image = nil
        hideTextFields()
        topTextField.text = topPlaceholderText
        bottomTextField.text = bottomPlaceholderText
        infoLabel.hidden = false
        infoLabel.text = "select an image"
        shareButton.enabled = false
        cancelButton.enabled = false
    }
    
    // MARK: - Generate memedImage
    func generateMemedImage() -> UIImage {
        // Hide toolbar and navbar
        topNavBar.hidden = true
        bottomToolbar.hidden = true
        
        // Render view to an image at 0.0 scale to preserve scale factor to device's main screen
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, true, 0.0)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar 
        topNavBar.hidden = false
        bottomToolbar.hidden = false
        
        return memedImage
    }
    
    //TODO: save meme
//    func save() {
//        // Create the meme 
//        let meme = Meme(text: textField.text!, image: imageView.image, memedImage: memedImage)
//    }
    
    // MARK: - Image picker delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Conditionally unwrap dictionary key and cast to UIImage
        if let userImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = userImage
            // Post image notifications
            postImageSelectedNotification()
            
            // Show textfields and set info label text
            infoLabel.text = "enter meme text"
            showTextFields()
            
            // Determine height of scaled image inside imageView
            let rect = AVMakeRectWithAspectRatioInsideRect(userImage.size, imagePickerView.bounds)
            positionTextFields(rect)
            
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        unsubscribeToImageSelectedNotifications()
    }
    
    func deviceRotated() {
//        print(self.imagePickerView.image?.size)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if self.topTextField.isFirstResponder() || self.bottomTextField.isFirstResponder() {
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
        if self.bottomTextField.isFirstResponder() {
            UIView.animateWithDuration(0.5, animations: {
                self.view.frame.origin.y -= self.getKeyboardHeight(notification)
            })
        }
    }
    
    // Move frame back to initial position when keyboardWillHideNotification is received
    func keyboardWillHide(notification: NSNotification) {
        let initialViewRect: CGRect = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)
        if self.bottomTextField.isFirstResponder() {
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
        if self.imagePickerView.image != nil && topTextField.text != topPlaceholderText && bottomTextField.text != bottomPlaceholderText {
            shareButton.enabled = true
        }
    }
    
    // Enable cancel button after user selects an image
    func enableCancelButton() {
        cancelButton.enabled = true
    }
    
    // MARK: - Utilities
    func positionTextFields(aspectRatioRect: CGRect) {
        
        // Calculate text field vertical spacing
        let verticalSpacing = (imagePickerView.bounds.height - aspectRatioRect.size.height) / 2
        
        // Position text fields inside scaled image
        topTextFieldVerticalConstraint.constant = verticalSpacing
        bottomTextFieldVerticalConstraint.constant = verticalSpacing
    }
    
    // Close keyboard whenever user taps anywhere outside of keyboard:
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // Hide/show navbar and toolbar
    func hideShowToolbars() {
        if topNavBar.hidden == false && bottomToolbar.hidden == false {
            topNavBar.hidden = true
            bottomToolbar.hidden = true
        }
        else {
            topNavBar.hidden = false
            bottomToolbar.hidden = false
        }
    }
    
    func hideTextFields() {
        topTextField.hidden = true
        bottomTextField.hidden = true
    }
    
    func showTextFields() {
        topTextField.hidden = false
        bottomTextField.hidden = false
    }

}

// Position text fields within user's image depending on device orientation
// Add code to make Cancel button work
// Add info label to notify user to select image 
// Hide top and bottom text fields initially until an image is selected
// Rearrange order of textfields and toolbars so no overlapping occurs
