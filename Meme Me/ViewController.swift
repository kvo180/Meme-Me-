//
//  ViewController.swift
//  Meme Me
//
//  Created by Khoa Vo on 9/14/15.
//  Copyright (c) 2015 AppSynth. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // MARK: - Properties and Outlets
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topNavBar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    let topPlaceholderText:String = "TOP"
    let bottomPlaceholderText:String = "BOTTOM"
    let imageSelected:String = "com.khoavo.imageSelectedNotificationKey"
    let textEntered:String = "com.khoavo.textEnteredNotificationKey"
    
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
        
        // Set share button to be disable initially 
        shareButton.enabled = false
        
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
        
        // Set text field delegates
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // Add tap gestures to dismiss keyboard when user taps outside of text field
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
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
        print("shared")
        // TODO: generate a memed image 
        // TODO: define an instance of the ActivityViewController 
        // TODO: pass the ActivityViewController a memedImage as an activity item 
        // TODO: present the ActivityViewController
    }
    
    func generateMemeImage() -> UIImage {
        // Hide toolbar and navbar
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar 
        
        return memedImage
    }
    
//    func save() {
//        // Create the meme 
//        let meme = Meme(text: textField.text!, image: imageView.image, memedImage: memedImage)
//    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
    }
    
    // MARK: - Image picker delegate methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // Conditionally unwrap dictionary key and cast to UIImage
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = image
            postImageSelectedNotification()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        unsubscribeToImageSelectedNotifications()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        unsubscribeToImageSelectedNotifications()
    }
    
    // MARK: - Text field delegate methods
    func textFieldDidBeginEditing(textField: UITextField) {
        
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
    
    // Close keyboard whenever user taps anywhere outside of keyboard:
    func dismissKeyboard() {
        self.view.endEditing(true)
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
        print("image picker subscribed")
    }
    
    func unsubscribeToImageSelectedNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: imageSelected, object: nil)
        print("image picker unsubscribed")
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
    
    // MARK: - Enable share button
    func postImageSelectedNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(imageSelected, object: self, userInfo: nil)
    }
    
    func postTextEnteredNotification() {
        NSNotificationCenter.defaultCenter().postNotificationName(textEntered, object: self, userInfo: nil)
    }
    
    func enableShareButton() {
        // Enable button when meme is complete
        if self.imagePickerView.image != nil && topTextField.text != topPlaceholderText && bottomTextField.text != bottomPlaceholderText {
            shareButton.enabled = true
        }
    }

}


