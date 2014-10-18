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
    sepia.value1 = "inputIntensity"
    sepia.value2 = "inputIntensity"
    sepia.value1Default = 1.0
    sepia.value2Default = 1.0
    
    
    var gaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    gaussianBlur.name = "CIGaussianBlur"
    gaussianBlur.readableName = "Blur"
    gaussianBlur.value1 = "CISepiaTone"
    gaussianBlur.value2 = "Sepia"
    gaussianBlur.value1Default = 1.0
    gaussianBlur.value2Default = 1.0
    
    var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    pixellate.name = "CIPixellate"
    pixellate.readableName = "Pixellate"
    pixellate.value1 = "CISepiaTone"
    pixellate.value2 = "Sepia"
    pixellate.value1Default = 1.0
    pixellate.value2Default = 1.0
    
    var gammaAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    gammaAdjust.name = "CIGammaAdjust"
    gammaAdjust.readableName = "Gamma"
    gammaAdjust.value1 = "CISepiaTone"
    gammaAdjust.value2 = "Sepia"
    gammaAdjust.value1Default = 1.0
    gammaAdjust.value2Default = 1.0
    
    var exposureAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    exposureAdjust.name = "CIExposureAdjust"
    exposureAdjust.readableName = "Exposure"
    exposureAdjust.value1 = "CISepiaTone"
    exposureAdjust.value2 = "Sepia"
    exposureAdjust.value1Default = 1.0
    exposureAdjust.value2Default = 1.0
    
    var chrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    chrome.name = "CIPhotoEffectChrome"
    chrome.readableName = "Chrome"
    chrome.value1 = "CISepiaTone"
    chrome.value2 = "Sepia"
    chrome.value1Default = 1.0
    chrome.value2Default = 1.0
    
    var instant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    instant.name = "CIPhotoEffectInstant"
    instant.readableName = "Instant"
    instant.value1 = "CISepiaTone"
    instant.value2 = "Sepia"
    instant.value1Default = 1.0
    instant.value2Default = 1.0
    
    var mono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    mono.name = "CIPhotoEffectMono"
    mono.readableName = "Mono"
    mono.value1 = "CISepiaTone"
    mono.value2 = "Sepia"
    mono.value1Default = 1.0
    mono.value2Default = 1.0
    
    var noir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    noir.name = "CIPhotoEffectNoir"
    noir.readableName = "Noir"
    noir.value1 = "CISepiaTone"
    noir.value2 = "Sepia"
    noir.value1Default = 1.0
    noir.value2Default = 1.0
    
    var tonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    tonal.name = "CIPhotoEffectTonal"
    tonal.readableName = "Tonal"
    tonal.value1 = "CISepiaTone"
    tonal.value2 = "Sepia"
    tonal.value1Default = 1.0
    tonal.value2Default = 1.0
    
    var posterize = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    posterize.name = "CIColorPosterize"
    posterize.readableName = "Posterize"
    posterize.value1 = "CISepiaTone"
    posterize.value2 = "Sepia"
    posterize.value1Default = 1.0
    posterize.value2Default = 1.0
    
    var sharpen = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
    sharpen.name = "CISharpenLuminance"
    sharpen.readableName = "Sharpen"
    sharpen.value1 = "CISepiaTone"
    sharpen.value2 = "Sepia"
    sharpen.value1Default = 1.0
    sharpen.value2Default = 1.0

    var error : NSError?
    self.managedObjectContext.save(&error)
    println(error)
    
  }
}
