//
//  CoreDataSeeder.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/14/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation
import CoreData

class CoreDataSeeder {
  var managedObjectContext: NSManagedObjectContext!
  
  init(context : NSManagedObjectContext){
    self.managedObjectContext = context
  }
  
  func seedCoreData() {
    
    var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    sepia.name = "CISepiaTone"
    sepia.readableName = "Sepia"
    
    var gaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    gaussianBlur.name = "CIGaussianBlur"
    gaussianBlur.readableName = "Blur"
    
    var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    pixellate.name = "CIPixellate"
    pixellate.readableName = "Pixellate"
    
    var gammaAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    gammaAdjust.name = "CIGammaAdjust"
    gammaAdjust.readableName = "Gamma"
    
    var exposureAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    exposureAdjust.name = "CIExposureAdjust"
    exposureAdjust.readableName = "Exposure"
    
    var chrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    chrome.name = "CIPhotoEffectChrome"
    chrome.readableName = "Chrome"
    
    var instant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    instant.name = "CIPhotoEffectInstant"
    instant.readableName = "Instant"
    
    var mono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    mono.name = "CIPhotoEffectMono"
    mono.readableName = "Mono"
    
    var noir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    noir.name = "CIPhotoEffectNoir"
    noir.readableName = "Noir"
    
    var tonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    tonal.name = "CIPhotoEffectTonal"
    tonal.readableName = "Tonal"
    
    var posterize = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    posterize.name = "CIColorPosterize"
    posterize.readableName = "Posterize"
    
    var sharpen = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    sharpen.name = "CISharpenLuminance"
    sharpen.readableName = "Sharpen"

    var error : NSError?
    self.managedObjectContext.save(&error)
    println(error)
    
  }
}
