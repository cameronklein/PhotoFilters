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
  var lastClickedIndex : Int?
  var collectionViewInBounds = false
  var requestedGalleryType : GalleryType = .Random
  
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
    
    saveButton.enabled = false
    var options = [kCIContextWorkingColorSpace : NSNull()]
    var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.GPUContext = CIContext(EAGLContext: myEAGLContext, options: options)
    
    self.appDel = UIApplication.sharedApplication().delegate as AppDelegate
    let context = appDel.managedObjectContext
    
    self.fetchFilters()
    self.generateThumbnails()
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    
    tapRecognizer = UITapGestureRecognizer()
    tapRecognizer.addTarget(self, action: "buttonPressed:")
    imageView.addGestureRecognizer(tapRecognizer)
    imageView.userInteractionEnabled = true
    
    imageView.layer.borderColor = UIColor.whiteColor().CGColor
    imageView.layer.borderWidth = 2
    
    let seeder = CoreDataSeeder(context: context!)
    //seeder.seedCoreData()
    
    let buttonsArray = [cameraButton,twitterButton,settingsButton]
    for button in buttonsArray{
      button.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
    }
    logo.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
    self.imageView.addNaturalOnTopEffect(maximumRelativeValue: 10.0)
    
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(false)
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(false)
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
      destinationVC.type = requestedGalleryType
      destinationVC.delegate = self
    }
  }
  
  // MARK: - GalleryDelegate
  
  func didTapOnPicture(image: UIImage) {

    imageView.removeGestureRecognizer(tapRecognizer)
    println("Did Tap")
    saveButton.enabled = true
    placeholderImage = image
    imageHasBeenSet = true
    getThumbnailOfMainImage()
    generateThumbnails()
    collectionView.reloadData()
    imageView.image = image
    
    println(image.size)
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
    
    if lastClickedIndex != indexPath.row{
      let orientation = placeholderImage!.imageOrientation.toRaw()
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

      var imageFilter = CIFilter(name: filters[indexPath.row].name)
      imageFilter.setDefaults()
      imageFilter.setValue(image, forKey: kCIInputImageKey)
      var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
      var extent = result.extent()
      var imageRef = self.GPUContext!.createCGImage(result, fromRect: extent)
      
      UIView.transitionWithView(self.imageView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
        self.imageView.image = UIImage(CGImage: imageRef)
      }) { (success) -> Void in
      }
      lastClickedIndex = indexPath.row
    }
  }
  
  // MARK: - Helper Methods
  
  override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
    println("Animation Did Stop Function Called")
    if flag == true {
      println("Flag = true")
      self.imageView.image = placeholderImage
      self.tempView?.removeFromSuperview()
    }
  }
  
  func fetchFilters(){
    var fetchRequest = NSFetchRequest(entityName: "Filter")
    
    let context = appDel.managedObjectContext
    
    var error : NSError?
    let results = context!.executeFetchRequest(fetchRequest, error: &error)
    println(error)
    
    if let filters = results as? [Filter]{
      self.filters = filters
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
    let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
      let picker = UIImagePickerController()
      picker.allowsEditing = true
      picker.sourceType = UIImagePickerControllerSourceType.Camera
      picker.delegate = self
      self.presentViewController(picker, animated: true, completion: nil)
    }
    
    let camera2Action = UIAlertAction(title: "AV Camera Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
      let window : UIWindow = UIApplication.sharedApplication().keyWindow
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
    
    let galleryAction = UIAlertAction(title: "Random Picture Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
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
    
    let window : UIWindow = UIApplication.sharedApplication().keyWindow
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
      collectionViewBottomConstraint.constant -= 140
      imageTopConstraint.constant += 50
      collectionViewInBounds = false
    } else{
      collectionViewBottomConstraint.constant += 140
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
}

