//
//  ViewController.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import CoreData

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

  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var logo: UIImageView!
  @IBOutlet weak var twitterButton: UIButton!
  @IBOutlet weak var cameraButton: UIButton!
  @IBOutlet weak var settingsButton: UIButton!
  // MARK - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
  
  func didTapOnPicture(image: UIImage, frame: CGRect? = nil) {

    imageView.removeGestureRecognizer(tapRecognizer)

    
    tempView = UIImageView(frame: frame!)
    tempView!.image = image
    self.view.addSubview(tempView!)
    self.placeholderImage = image
    self.imageHasBeenSet = true
    self.getThumbnailOfMainImage()
    self.generateThumbnails()
    collectionView.reloadData()
    
    
    let x = ((self.imageView.frame.origin.x + tempView!.frame.origin.x) / 2)
    let y = ((self.imageView.frame.origin.y + tempView!.frame.origin.y) / 2) - 100
    let height = self.imageView.frame.height * 1.5
    let width = self.imageView.frame.width * 1.5
    let rect = CGRect(x: x, y: y, width: width, height: height)
    
    let thePath = CGPathCreateMutable()
    CGPathMoveToPoint(thePath, nil, tempView!.center.x, tempView!.center.y)
    let maxY = tempView!.center.y - 300
    var maxX : CGFloat!
    if tempView!.center.x < imageView.center.x {
      maxX = tempView!.center.x
    } else {
      maxX = imageView.center.x
    }
    
    CGPathAddCurveToPoint(thePath, nil, tempView!.center.x, maxY, maxX, maxY, imageView.center.x, imageView.center.y)
    let animation = CAKeyframeAnimation(keyPath: "position")
    animation.path = thePath
    //animation.duration = 1.0
    
    let multiplier = imageView.frame.height / tempView!.frame.size.height
    let originalScale = CATransform3DMakeScale(1.0, 1.0, 1.0)
    let newScale = CATransform3DMakeScale(multiplier, multiplier, 0.0)
    println(multiplier)
    let value1 = NSValue(CATransform3D: originalScale)
    let value2 = NSValue(CATransform3D: newScale)
    let array : [AnyObject] = [value1, value2]
    let valuesArray = NSArray(array: array)
    let timeArray = NSArray(objects: NSNumber(float: 0.0), NSNumber(float: 1.0))
    
    let animationTransform = CAKeyframeAnimation(keyPath: "bounds")
    
    //animationTransform.duration = 1.0
    let initialBounds = NSValue(CGRect: tempView!.bounds)
    let secondBounds = NSValue(CGRect: tempView!.bounds)
    let finalBounds = NSValue(CGRect: imageView.bounds)

    animationTransform.values = [initialBounds, secondBounds, finalBounds]
    animationTransform.keyTimes = [0.0, 0.5, 1.0]
    animationTransform.delegate = self
    
//    self.tempView!.layer.addAnimation(animationTransform, forKey: "transform")
//    self.tempView!.layer.addAnimation(animation, forKey: "position")
    
//    UIView.animateWithDuration(1.0, delay: 0.0, options: nil, animations: { () -> Void in

//      self.tempView!.layer.addAnimation(animationTransform, forKey: "transform")
//      self.tempView!.layer.addAnimation(animation, forKey: "position")
      
//      self.tempView!.bounds = self.imageView.bounds
//      self.tempView!.center = self.imageView.center
//      }) { (success) -> Void in
//        println("Completion called!")
//        if success == true {
//          println("Success == true")
//          self.imageView.image = image
//          self.tempView!.removeFromSuperview()
//        }
//    }
      
      self.imageView.image = image
      self.tempView!.removeFromSuperview()
  }
  
  // MARK - UIImagePickerControllerDelegate
  
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
  
  // MARK - UICollectionViewDataSource
  
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
  
  // MARK - UICollectionView Delegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    if lastClickedIndex != indexPath.row{
      var image = CIImage(image: placeholderImage!)
      var imageFilter = CIFilter(name: filters[indexPath.row].name)
      imageFilter.setDefaults()
      imageFilter.setValue(image, forKey: kCIInputImageKey)
      var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
      var extent = result.extent()
      var imageRef = self.GPUContext!.createCGImage(result, fromRect: extent)
      
      UIView.transitionWithView(self.imageView, duration: 0.2, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
        self.imageView.image = UIImage(CGImage: imageRef)
      }) { (success) -> Void in
      }
      lastClickedIndex = indexPath.row
    }

    
  }
  
  // MARK - Helper Methods
  
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
  
  // MARK - IBActions
  
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
  
  
  @IBAction func tweetButtonPressed(sender: AnyObject) {
    
    let window : UIWindow = UIApplication.sharedApplication().keyWindow
    UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, 1.0)
    self.view.layer.renderInContext(UIGraphicsGetCurrentContext())
    let screenshot = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    let composeTweetVC = storyboard?.instantiateViewControllerWithIdentifier("COMPOSE") as ComposeTweetViewController
    composeTweetVC.image = self.imageView.image
    
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
      collectionViewBottomConstraint.constant -= 140
      imageTopConstraint.constant += 50
      collectionViewInBounds = false
    }
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutSubviews()
    })
  }
  
  @IBAction func swipedUp(sender: AnyObject) {
    if collectionViewInBounds == false{
      collectionViewBottomConstraint.constant += 140
      imageTopConstraint.constant -= 50
      collectionViewInBounds = true
    }
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutSubviews()
    })

  }
}

