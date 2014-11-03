//
//  ViewController.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import CoreData
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, GalleryDelegate {
  
  var tapRecognizer : UITapGestureRecognizer!
  var placeholderImage : UIImage?
  var tempView : UIImageView?
  var filters : [Filter]!
  var filterThumbnails = [FilterThumbnail]()
  var imageQueue = NSOperationQueue()
  var appDel : AppDelegate!
  var GPUContext : CIContext!
  var imageHasBeenSet = false
  var originalThumbnail : UIImage?
  var collectionViewInBounds = false
  var requestedGalleryType : GalleryType = .Random
  var currentFilter : Filter?
  var panRecognizer : UIPanGestureRecognizer!
  
  @IBOutlet weak var panLabel: UILabel!
  @IBOutlet weak var cameraLabel: UILabel!
  @IBOutlet weak var tweetLabel: UILabel!
  @IBOutlet weak var filterLabel: UILabel!
  @IBOutlet weak var saveButton: UIButton!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var logo: UIImageView!
  @IBOutlet weak var twitterButton: UIButton!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  
  // MARK: - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    var options = [kCIContextWorkingColorSpace : NSNull()]
    var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.GPUContext = CIContext(EAGLContext: myEAGLContext, options: options)
    
    self.appDel = UIApplication.sharedApplication().delegate as AppDelegate
    let context = appDel.managedObjectContext

    self.fetchFilters()
    self.generateThumbnails()
    
    tapRecognizer = UITapGestureRecognizer()
    tapRecognizer.addTarget(self, action: "buttonPressed:")
    imageView.addGestureRecognizer(tapRecognizer)
    imageView.userInteractionEnabled = true
    
    imageView.layer.borderColor = UIColor.whiteColor().CGColor
    imageView.layer.borderWidth = 2

    let buttonsArray = [cameraButton, twitterButton, settingsButton]
    for button in buttonsArray{
      button.addNaturalOnTopEffect(maximumRelativeValue: 10.0)
    }
    logo.addNaturalOnTopEffect(maximumRelativeValue: 10.0)
    self.imageView.addNaturalOnTopEffect(maximumRelativeValue: 5.0)
    
    panLabel.alpha = 0.0
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(true)
    
    UIView.animateWithDuration(2.0,
      delay: 1.5,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
      self.cameraLabel.alpha = 0
      },
      completion: nil)
    }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
    if segue.identifier == "SHOW_GALLERY"{
      
      let window : UIWindow = UIApplication.sharedApplication().keyWindow!
      UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 1.0)
      self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
      let screenshot = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      let destinationVC = segue.destinationViewController as GalleryViewController
      destinationVC.backgroundImage = screenshot
      destinationVC.type = requestedGalleryType
      destinationVC.delegate = self
    }
  }

  
  // MARK: - GalleryDelegate
  
  func didTapOnPicture(image: UIImage) {

    imageView.removeGestureRecognizer(tapRecognizer)
    saveButton.enabled = true
    placeholderImage = image
    imageHasBeenSet = true
    getThumbnailOfMainImage()
    generateThumbnails()
    collectionView.reloadData()
    imageView.image = image
    
    twitterButton.hidden = false
    settingsButton.hidden = false
    tweetLabel.hidden = false
    filterLabel.hidden = false
    
    UIView.animateWithDuration(2.0, delay: 1.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
      self.tweetLabel.alpha = 0.0
      self.filterLabel.alpha = 0.0
    }, completion: nil)

    println("Image size = \(image.size)")
  }
  
  // MARK: - UIImagePickerControllerDelegate
  
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    imageView.image = info["UIImagePickerControllerEditedImage"] as? UIImage
    self.placeholderImage = imageView.image
    imageView.removeGestureRecognizer(tapRecognizer)
    
    self.imageHasBeenSet = true
    self.getThumbnailOfMainImage()
    self.generateThumbnails()
    collectionView.reloadData()
    
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  // MARK: - UICollectionViewDataSource
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if imageHasBeenSet{
      println("Collection View asking for \(filters.count) cells!")
      return filters.count
    } else{
      return 0
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterCell
    
    let wrapper = filterThumbnails[indexPath.row]
    
    if wrapper.filteredThumbnail != nil{
      cell.imageView.image = wrapper.filteredThumbnail
    } else {
      wrapper.generateThumbnail({ (image) -> Void in
        cell.imageView.image = image
      })
    }
    cell.label.text = wrapper.readableName
      
    return cell
  }
  
  // MARK: - UICollectionView Delegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
  
      let image = getCIImageWithProperOrientation()
      currentFilter = filters[indexPath.row]
    
      UIView.transitionWithView(self.imageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
        self.imageView.image = self.applyFilterToImage(image, filter: self.currentFilter!, value1: nil, value2: nil)
        self.panLabel.alpha = 1.0
        return ()
      }) { (success) -> Void in
      }

    if panRecognizer == nil {
      panRecognizer = UIPanGestureRecognizer()
      panRecognizer.addTarget(self, action: "userDidPan:")
      self.imageView.addGestureRecognizer(panRecognizer)
    }
  }
  
  // MARK: - Helper Methods
  
  func applyFilterToImage(image: CIImage, filter: Filter, value1: Float?, value2: Float?) -> UIImage{
    
    
    var imageFilter = CIFilter(name: filter.name)
    imageFilter.setDefaults()
    imageFilter.setValue(image, forKey: kCIInputImageKey)
    
    if filter.name == "CIAdditionCompositing" {
      println("Trying!!")
      var paper = UIImage(named: "paper")
      var imageSize : CGSize = image.extent().size
      
      UIGraphicsBeginImageContextWithOptions(imageSize, true, 1.0)
      paper!.drawInRect(CGRect(origin: CGPoint(x: 0, y: 0), size: imageSize))
      paper = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      imageFilter.setValue(CIImage(image: paper), forKey: "inputBackgroundImage")
      
    } else{
      if value1 != nil{
        imageFilter.setValue(value1!, forKey: filter.value1)
      }
      if value2 != nil && filter.value1 != filter.value2{
        imageFilter.setValue(value2!, forKey: filter.value2)
      }
    }
    
    var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
    var extent = result.extent()
    var imageRef = self.GPUContext!.createCGImage(result, fromRect: extent)
    
    return UIImage(CGImage: imageRef!)!
  }
  
  
  func getCIImageWithProperOrientation() -> CIImage {
    let orientation = placeholderImage!.imageOrientation.rawValue
    println("Orientation = \(orientation)")
    var image = CIImage(image: placeholderImage!)
    switch orientation {
    case 1:
      image = image.imageByApplyingOrientation(3)
    case 2:
      println("Unknown. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 3:
      image = image.imageByApplyingOrientation(6)
    case 4:
      println("Unknown. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 5:
      println("Unknown. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 6:
      println("Unknown. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 7:
      println("Unknown. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 7:
      println("Unknown. Trying 1")
      image = image.imageByApplyingOrientation(1)
    default:
      println("Good to go!")
    }
    return image
  }
  
  func fetchFilters(){
    var fetchRequest = NSFetchRequest(entityName: "Filter")
    
    let context = appDel.managedObjectContext
    
    var error : NSError?
    let results = context!.executeFetchRequest(fetchRequest, error: &error)
    println(error)
    
    if let filters = results as? [Filter]{
      self.filters = filters
      if filters.count == 0 {
        let seeder = CoreDataSeeder(context: context!)
        seeder.seedCoreData()
        self.fetchFilters()
      }
    }
    
    println("\(filters.count) filters retrieved!")
    
  }
  
  func getThumbnailOfMainImage() {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    self.placeholderImage!.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
  }
  
  func generateThumbnails(){
    if let image = originalThumbnail{
      filterThumbnails.removeAll(keepCapacity: true)
      for filter in filters {
        filterThumbnails.append(FilterThumbnail(name: filter.name, readable: filter.readableName, thumbnail: image, queue: imageQueue, context: GPUContext))
      }
      println("\(filterThumbnails.count) filter thumbnails generated!")
    }
  }
  
  func resetThumbnails() {
    filterThumbnails.removeAll(keepCapacity: true)

  }
  
  // MARK: - IBActions
  
  @IBAction func buttonPressed(sender: AnyObject){
    
    let alertController = UIAlertController(title: nil, message: "Import Photo From", preferredStyle: UIAlertControllerStyle.ActionSheet)
    let cameraAction = UIAlertAction(title: "Camera (UIImagePicker)", style: UIAlertActionStyle.Default) { (action) -> Void in
      let picker = UIImagePickerController()
      picker.allowsEditing = true
      picker.sourceType = UIImagePickerControllerSourceType.Camera
      picker.delegate = self
      self.presentViewController(picker, animated: true, completion: nil)
    }
    
    let camera2Action = UIAlertAction(title: "Camera (Photos Framework)", style: UIAlertActionStyle.Default) { (action) -> Void in
      let window : UIWindow = UIApplication.sharedApplication().keyWindow!
      UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 1.0)
      self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
      let screenshot = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      let cameraVC = self.storyboard?.instantiateViewControllerWithIdentifier("AV_FRAMEWORK") as CameraViewController
      cameraVC.backgroundImage = screenshot

      cameraVC.delegate = self
      
      self.presentViewController(cameraVC, animated: true, completion: { () -> Void in
        println("Presented!")
      })
    }
    
    let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.requestedGalleryType = .PhotoAPI
      self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
    }
    
    let galleryAction = UIAlertAction(title: "Stock Photos", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.requestedGalleryType = .Random
      self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
    
    if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) || UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) {
      alertController.addAction(cameraAction)
      alertController.addAction(camera2Action)
    }
    alertController.addAction(libraryAction)
    alertController.addAction(galleryAction)
    alertController.addAction(cancelAction)
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  
  @IBAction func tweetButtonPressed(sender: AnyObject) {
    
    let window : UIWindow = UIApplication.sharedApplication().keyWindow!
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 1.0)
    self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
    let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let composeTweetVC = storyboard?.instantiateViewControllerWithIdentifier("COMPOSE") as ComposeTweetViewController
    
    let postSize = CGRect(x: 0, y: 0, width: 400, height: 400)
    UIGraphicsBeginImageContext(CGSize(width: 400, height: 400))
    self.imageView.image!.drawInRect(postSize)
    let smallerImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    composeTweetVC.image = smallerImage
    composeTweetVC.backgroundImage = screenshot
    
    self.presentViewController(composeTweetVC, animated: true) { () -> Void in
      println("Presented!")
    }
  }

  @IBAction func settingsButtonPressed(sender: AnyObject) {
    
    if collectionViewInBounds{
      collectionViewBottomConstraint.constant -= 156
      imageTopConstraint.constant += 50
      collectionViewInBounds = false
    } else{
      collectionViewBottomConstraint.constant += 156
      imageTopConstraint.constant -= 50
      collectionViewInBounds = true
    }
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutSubviews()
    })
  }
  
  @IBAction func swipedDown(sender: AnyObject) {
    if collectionViewInBounds{
      collectionViewBottomConstraint.constant -= 156
      imageTopConstraint.constant += 50
      collectionViewInBounds = false
    }
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutSubviews()
    })
  }
  
  @IBAction func swipedUp(sender: AnyObject) {
    if collectionViewInBounds == false{
      collectionViewBottomConstraint.constant += 156
      imageTopConstraint.constant -= 50
      collectionViewInBounds = true
    }
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutSubviews()
    })

  }
  
  @IBAction func clickedSave(sender: AnyObject) {
    let library = PHPhotoLibrary.sharedPhotoLibrary()
    
    library.performChanges({ () -> Void in
      println("Trying to register change request...")
      PHAssetChangeRequest.creationRequestForAssetFromImage(self.imageView.image)
    }, completionHandler: { (success, error) -> Void in
      if success{
        let alert = UIAlertController(title: "Photo Saved!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
      }
    })
  }
  
  func userDidPan(sender: UIPanGestureRecognizer){
    let location = sender.locationInView(self.imageView)
    let x : Float = Float(location.x / imageView.frame.width * 2.0)
    let y : Float = Float(1 - location.y / imageView.frame.height * 2.0)
    
    let finalX = x * currentFilter!.value1Default
    let finalY = y * currentFilter!.value2Default
    
    let orientation = placeholderImage!.imageOrientation.rawValue
    println("Orientation = \(orientation)")
    var image = CIImage(image: placeholderImage!)
    switch orientation {
    case 1:
      image = image.imageByApplyingOrientation(3)
    case 2:
      println("Don't know what orientation transform to use. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 3:
      image = image.imageByApplyingOrientation(6)
    case 4:
      println("Don't know what orientation transform to use. Trying 1.")
      image = image.imageByApplyingOrientation(1)
    case 5:
      println("Don't know what orientation transform to use. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 6:
      println("Don't know what orientation transform to use. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 7:
      println("Don't know what orientation transform to use. Trying 1")
      image = image.imageByApplyingOrientation(1)
    case 7:
      println("Don't know what orientation transform to use. Trying 1")
      image = image.imageByApplyingOrientation(1)
    default:
      println("Good to go!")
    }
    
    println("Applying filter with values x: \(finalX) y: \(finalY)")
    
    if currentFilter!.name == "CICircleSplashDistortion" {
      self.imageView.image = self.applyFilterToImage(image, filter: currentFilter!, value1: x, value2: y)
    } else {
      self.imageView.image = self.applyFilterToImage(image, filter: currentFilter!, value1: finalX, value2: finalY)
    }
  }
}

