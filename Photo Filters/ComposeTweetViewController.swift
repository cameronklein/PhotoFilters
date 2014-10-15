//
//  ComposeTweetViewController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/10/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
  
  @IBOutlet weak var miniView: UIView!
  
  @IBOutlet weak var textField: UITextView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var postButton: UIButton!
  @IBOutlet weak var composeLabel: UILabel!
  var backgroundImage : UIImage!

  var networkController : NetworkController!
  var image : UIImage?
  
  //MARK - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.networkController = NetworkController()
    
    textField.layer.borderColor = UIColor.blackColor().CGColor
    textField.layer.borderWidth = 1
    textField.layer.cornerRadius = 10
    textField.clipsToBounds = true
    
    textField.delegate = self
    miniView.layer.cornerRadius = 10
    miniView.clipsToBounds = true
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.imageView.image = image

  }
  override func viewDidAppear(animated: Bool) {
    self.view.backgroundColor = UIColor(patternImage: backgroundImage)
  }

  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK - Helper Methods

  @IBAction func post(sender: UIButton) {
    networkController.postTweet(textField.text, image: image!, completionHandler: { (errorDescription) -> (Void) in
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        if errorDescription == nil {
          self.textField.text = nil
          let alert = UIAlertController(title: "Success!", message: "Tweet Posted!", preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "Great!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
          })
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        } else {
          let alert = UIAlertController(title: "Uh oh!", message: "Something went wrong. Try again?", preferredStyle: UIAlertControllerStyle.Alert)
          let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
          alert.addAction(ok)
          self.presentViewController(alert, animated: true, completion: nil)
        }
      })
    })
  }
  
  @IBAction func cancelButtonPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func textViewShouldEndEditing(textView: UITextView) -> Bool {
    textField.resignFirstResponder()
    return false
  }
  
}





