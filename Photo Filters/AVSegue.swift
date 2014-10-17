//
//  DropInSegue.swift
//  Class Roster
//
//  Created by Cameron Klein on 9/11/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

@objc(AVSegue)

class AVSegue: UIStoryboardSegue {
  
  var source : ViewController!
  var destination : CameraViewController!
  var overlayView : UIView!
  var screenshot : UIView!
  var appdel : AppDelegate!
  
  
  override func perform () {
    source = self.sourceViewController as ViewController
    destination = self.destinationViewController as CameraViewController
    screenshot = source.view.snapshotViewAfterScreenUpdates(true)
    
    source.presentViewController(destination, animated: false) { () -> Void in
      self.destination.view.addSubview(self.screenshot)
      self.screenshot.sendSubviewToBack(self.screenshot)
      self.screenshot.alpha = 0.5
      
      UIView.animateWithDuration(1.0, animations: { () -> Void in
        self.destination.capturePreviewImageView.alpha = 1.0
      })
    }
    
    
    
    
  }
}