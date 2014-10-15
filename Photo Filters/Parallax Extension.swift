//
//  NaturalMotion.swift
//
//  Created by Maciej Swic on 2014-06-06.
//  Released under the MIT license.
//

import UIKit

extension UIView {
  
  func addNaturalOnTopEffect(maximumRelativeValue : Float = 20.0) {
    //Horizontal motion
    var motionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis);
    motionEffect.minimumRelativeValue = maximumRelativeValue;
    motionEffect.maximumRelativeValue = -maximumRelativeValue;
    addMotionEffect(motionEffect);
    
    //Vertical motion
    motionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis);
    motionEffect.minimumRelativeValue = maximumRelativeValue;
    motionEffect.maximumRelativeValue = -maximumRelativeValue;
    addMotionEffect(motionEffect);
  }
  
  func addNaturalBelowEffect(maximumRelativeValue : Float = 20.0) {
    addNaturalOnTopEffect(maximumRelativeValue: -maximumRelativeValue)
  }
}
