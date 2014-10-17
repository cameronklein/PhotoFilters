//
//  ComposeTweetViewController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/10/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet weak var miniView: UIView!
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  @IBOutlet weak var charactersRemaining: UILabel!
  @IBOutlet weak var textField: UITextField!
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

    textField.clipsToBounds = true
    textField.delegate = self
    
    miniView.layer.cornerRadius = 10
    miniView.clipsToBounds = true
    charactersRemaining.text = "140"
    
    textField.addTarget(self, action: "textFieldDidChange", forControlEvents: UIControlEvents.EditingChanged)
    
    
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
    println("Post Called!")
    self.spinningWheel.startAnimating()
    networkController.postTweet(textField.text, image: image!, completionHandler: { (errorDescription) -> (Void) in
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.spinningWheel.stopAnimating()
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
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldShouldEndEditing(textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  func textFieldDidChange() {
    let numberOfChars = countElements(textField.text)
    let remaining = 140 - numberOfChars
    charactersRemaining.text = remaining.description
  }


}
