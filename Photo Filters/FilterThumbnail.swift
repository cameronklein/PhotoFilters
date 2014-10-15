//
//  FilterThumbnail.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/14/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

class FilterThumbnail {
  
  var originalThumbnail : UIImage
  var filteredThumbnail : UIImage?
  var imageQueue        : NSOperationQueue!
  var GPUContext        : CIContext?
  var filter            : CIFilter?
  var filterName        : String
  
  init(name: String, thumbnail: UIImage, queue: NSOperationQueue, context: CIContext) {
    self.filterName             = name
    self.originalThumbnail  = thumbnail
    self.imageQueue         = queue
    self.GPUContext         = context
  }
  
  func generateThumbnail (completionHandler: (image : UIImage) -> Void) {
    
    var image = CIImage(image: originalThumbnail)
    var imageFilter = CIFilter(name: filterName)
    imageFilter.setDefaults()
    imageFilter.setValue(image, forKey: kCIInputImageKey)
    
    var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
    var extent = result.extent()
    var imageRef = self.GPUContext!.createCGImage(result, fromRect: extent)
    self.filter = imageFilter
    self.filteredThumbnail = UIImage(CGImage: imageRef)
    
    NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
      completionHandler(image: self.filteredThumbnail!)
    }
  }
}
