//
//  ViewController.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate {

  @IBOutlet weak var imageView: UIImageView!
  var tapRecognizer : UITapGestureRecognizer!
  
  // MARK - Lifecycle Methods
  // TODO - Show corner thing when image added
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tapRecognizer = UITapGestureRecognizer()
    tapRecognizer.addTarget(self, action: "buttonPressed:")
    imageView.addGestureRecognizer(tapRecognizer)
    imageView.userInteractionEnabled = true
    
    imageView.layer.borderColor = UIColor.whiteColor().CGColor
    imageView.layer.borderWidth = 2
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "SHOW_GALLERY"{
      let window : UIWindow = UIApplication.sharedApplication().keyWindow
      UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 1.0)
      self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
      let screenshot = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      let destinationVC = segue.destinationViewController as GalleryViewController
      destinationVC.backgroundImage = screenshot
      destinationVC.delegate = self
    }
  }
  
  // MARK - MySampleDelegate
  
  func didTapOnPicture(image: UIImage) {
    imageView.image = image
    imageView.removeGestureRecognizer(tapRecognizer)
    println(imageView.frame.size)
  }
  
  // MARK - UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    imageView.image = info["UIImagePickerControllerEditedImage"] as? UIImage
    imageView.removeGestureRecognizer(tapRecognizer)
    
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK - Helper Methods
  
  @IBAction func buttonPressed(sender: AnyObject){
    
    let alertController = UIAlertController(title: nil, message: "Import Photo From", preferredStyle: UIAlertControllerStyle.ActionSheet)
    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
      let picker = UIImagePickerController()
      picker.allowsEditing = true
      picker.sourceType = UIImagePickerControllerSourceType.Camera
      picker.delegate = self
      self.presentViewController(picker, animated: true, completion: nil)
    }
    let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (action) -> Void in
      let picker = UIImagePickerController()
      picker.allowsEditing = true
      picker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
      picker.delegate = self
      
      self.presentViewController(picker, animated: true, completion: nil)
    }
    let galleryAction = UIAlertAction(title: "Random Picture Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
    }
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
    
    if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) || UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) {
      alertController.addAction(cameraAction)
    }
    alertController.addAction(libraryAction)
    alertController.addAction(galleryAction)
    alertController.addAction(cancelAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
    
  }
  

}

