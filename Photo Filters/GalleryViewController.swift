//
//  GalleryViewController.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import Photos

protocol GalleryDelegate {
  func didTapOnPicture(image: UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  @IBOutlet var pinchRecognizer: UIPinchGestureRecognizer!
  @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
  @IBOutlet weak var collectionViewTopContraint: NSLayoutConstraint!
  @IBOutlet weak var topLabel: UILabel!
  @IBOutlet weak var pager: UIPageControl!
  @IBOutlet weak var collectionView: UICollectionView!
  
  let imageQueue = NSOperationQueue()
  var backgroundImage : UIImage!
  var assetFetchResults: PHFetchResult!
  var assetCollection: PHAssetCollection!
  var imageManager: PHCachingImageManager!
  var assetCellSize: CGSize!
  var headerNames = [Int:String]()
  var collectionType : CollectionType = .Moments
  var type : GalleryType = .Random
  var layout : UICollectionViewFlowLayout!
  var initialSize : CGSize!
  var screenWidth : CGFloat!
  var isPinching = false
  
  var delegate : GalleryDelegate?
  
  // MARK: - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER")
    
    layout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    self.screenWidth = self.view.frame.width
    
    layout.minimumLineSpacing = screenWidth * 0.03
    layout.minimumInteritemSpacing = screenWidth * 0.03
    layout.sectionInset.left = screenWidth * 0.03
    layout.sectionInset.right = screenWidth * 0.03
    layout.itemSize = CGSize(width: screenWidth * 0.29, height: screenWidth * 0.29)
  
    self.initialSize = layout.itemSize
    
    switch type{
      
      case .Random:
        
        println("Random!")
        pager.hidden = true
        topLabel.hidden = true
        toolbarHeight.constant = 44
        collectionViewTopContraint.constant = -60
        
      case .PhotoAPI:
        
        self.imageManager = PHCachingImageManager()
        self.assetFetchResults = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Moment, subtype: PHAssetCollectionSubtype.Any, options: nil)
        
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var cellSize = flowLayout.itemSize
        
        self.assetCellSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        self.topLabel.text = "Moments"
        pager.currentPage = 1
    }
    
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(animated: Bool) {
    self.view.backgroundColor = UIColor(patternImage: backgroundImage)
    let swipeImage = UIImageView(image: UIImage(named: "Swipe"))
    swipeImage.alpha = 0.0

    swipeImage.center = CGPoint(x : UIScreen.mainScreen().bounds.width / 2, y : UIScreen.mainScreen().bounds.height / 2)
    self.view.bringSubviewToFront(swipeImage)
    self.view.addSubview(swipeImage)
    
    UIView.animateWithDuration(0.5,
      delay: 0.3,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
        swipeImage.alpha = 0.8
      }) { (success) -> Void in
          UIView.animateWithDuration(0.5,
            delay: 1.0,
            options: nil,
            animations: { () -> Void in
              swipeImage.alpha = 0.0
            },
            completion: { (success) -> Void in
        })
    }
  }
  
  // MARK: - UICollectionView Data Source
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    switch type {
    case .Random:
      return 6
    case .PhotoAPI:
      switch collectionType{
      case .Moments, .Albums:
        println("\(collectionType.toString()) looking for sections!")
        return assetFetchResults.count
      case .All:
        println("All looking for sections")
        return 1
      }
    }
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch type {
    case .Random:
      return 9
    case .PhotoAPI:
      println("\(collectionType.toString()) looking for items")
      switch collectionType{
      case .Moments, .Albums:
        var collection = self.assetFetchResults[section] as PHAssetCollection
        return collection.estimatedAssetCount
      case .All:
        println("All Assets: \(self.assetFetchResults.count) Found")
        return self.assetFetchResults.count
      }
      
    }
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    
    cell.userInteractionEnabled = false
    cell.imageView.image = nil
    cell.spinningWheel.startAnimating()
    var urlString : String!

    if cell.hasSetMotion == false {
      cell.addNaturalOnTopEffect(maximumRelativeValue: 20.0)
      cell.hasSetMotion = true
    }
    
    var currentTag = cell.tag + 1
    cell.tag = currentTag

    switch type{
      
      case .Random:
        fetchRandomImageForImagePath(indexPath, completionHandler: { (image) -> Void in
          if cell.tag == currentTag{
            cell.imageView.image = image
            cell.spinningWheel.stopAnimating()
            cell.userInteractionEnabled = true
          }
        })
        
      case .PhotoAPI:
        fetchImagesFromPhotosAPIForIndexPath(indexPath, completionHandler: { (image) -> Void in
          if cell.tag == currentTag{
            cell.imageView.image = image
            cell.spinningWheel.stopAnimating()
            cell.userInteractionEnabled = true
          }
        })
    }
    
    return cell
  }

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
      let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HEADER", forIndexPath: indexPath) as HeaderView
    
    switch type{
      
    case .Random:
      let categories = ["Animals", "Food" ,"Sports" ,"Nature", "People", "City"]
      view.label.text = categories[indexPath.section]
      
    case .PhotoAPI:
      switch collectionType{
      case .Moments:
        var collection = self.assetFetchResults[indexPath.section] as PHAssetCollection
        
        if let title = collection.localizedTitle {
          view.label.text = title
        } else {
          view.label.text = "Unnamed Moment"
        }
        
      case .Albums:
        var collection = self.assetFetchResults[indexPath.section] as PHAssetCollection
         view.label.text = collection.localizedTitle
      case .All:
        view.label.text = ""
      }
    }
    return view
  }
  
  // MARK: - UICollectionView Delegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    switch type{
      
    case .PhotoAPI:
      let cell = collectionView.cellForItemAtIndexPath(indexPath) as GalleryCell
      delegate?.didTapOnPicture(cell.imageView.image!)
      self.dismissViewControllerAnimated(true, completion: nil)
      let options = PHImageRequestOptions()
      options.networkAccessAllowed = true
      options.synchronous = false

      let asset = self.getAssetAtIndexPath(indexPath) as PHAsset
      self.imageManager.requestImageForAsset(asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.AspectFill, options: options) { (image, info) -> Void in
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          println("Block Called!")
          if let retrievedImage = image{
            println("Delegate Called!")
            self.delegate?.didTapOnPicture(retrievedImage)
          }
        })
      }
    case .Random:
      
      let cell = collectionView.cellForItemAtIndexPath(indexPath) as GalleryCell
      delegate?.didTapOnPicture(cell.imageView.image!)
      self.dismissViewControllerAnimated(true, completion: nil)
      
    }
  }
  
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: GalleryCell, forItemAtIndexPath indexPath: NSIndexPath) {
    cell.imageView.image = nil
  }
  
  // MARK: - Helper Methods
  
  func fetchRandomImageForImagePath(indexPath: NSIndexPath, completionHandler: (UIImage) -> Void) {
    
    let categories = ["animals", "food" ,"sports" ,"nature", "people", "city"]
    var urlString = "http://lorempixel.com/400/400/" + categories[indexPath.section]
    let url = NSURL(string: urlString)
    imageQueue.addOperationWithBlock { () -> Void in
      let data = NSData(contentsOfURL: url)
      let image = UIImage(data: data)
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        completionHandler(image)
      })
    }
    
  }
  
  func fetchImagesFromPhotosAPIForIndexPath(indexPath: NSIndexPath, completionHandler: (UIImage) -> Void) {
    let asset = self.getAssetAtIndexPath(indexPath)
    self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFit, options: nil) { (image, info) -> Void in
      completionHandler(image)
    }
  }
  
  func reloadCollections(){
    self.topLabel.text = self.collectionType.toString()
    switch self.collectionType{
    case .Moments, .Albums:
      self.assetFetchResults = PHAssetCollection.fetchAssetCollectionsWithType(collectionType.getCollectionType()!, subtype: PHAssetCollectionSubtype.Any, options: nil)
      self.collectionView.dataSource = self
      self.collectionView.reloadData()
    case .All:
      self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
      self.collectionView.dataSource = self
      self.collectionView.reloadData()
      println(assetFetchResults.count)
    }
  }

  func getAssetAtIndexPath(indexPath: NSIndexPath) -> PHAsset{
    if let collection = self.assetFetchResults[indexPath.section] as? PHAssetCollection{
      var assetArray = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
      return assetArray[indexPath.row] as PHAsset
    } else {
      return self.assetFetchResults[indexPath.row] as PHAsset
    }
  }
  
  func getRandomSectionTitleForSection(section : Int, completionHandler: (String) -> Void) {
    
      if headerNames.count <= section {
        let url = NSURL(string: "http://randomword.setgetgo.com/get.php")
        imageQueue.addOperationWithBlock({
          var error : NSError
          let data = NSData(contentsOfURL: url)
          NSOperationQueue.mainQueue().addOperationWithBlock({
            var string = NSString(data: data, encoding: NSASCIIStringEncoding).capitalizedString
            self.headerNames[section] = string
            completionHandler(string)
            return ()
          })
        })
      } else {
        completionHandler(headerNames[section]!)
      }
    }
  
  // MARK: - IBAction
  
  @IBAction func cancelPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  @IBAction func swipedLeft(sender: AnyObject) {
    if type == .PhotoAPI {
      self.collectionType.previous()
      println(self.collectionType.toString())
      if pager.currentPage == 0{
        pager.currentPage = 2
      } else{
        pager.currentPage = pager.currentPage - 1
      }
      UIView.animateWithDuration(0.3,
        delay: 0.0,
        options: UIViewAnimationOptions.CurveEaseIn,
        animations: { () -> Void in
          self.collectionView.center.x -= 400
        }) { (success) -> Void in
          self.collectionView.center.x += 800
          self.reloadCollections()
          UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
              self.collectionView.center.x -= 400
            }) { (success) -> Void in
              println("Yay!")
              
          }
      }
    }
  }
  @IBAction func swipedRight(sender: AnyObject) {
    if type == .PhotoAPI {
      self.collectionType.next()
      println(self.collectionType.toString())
      if pager.currentPage == 2{
        pager.currentPage = 0
      } else{
        pager.currentPage = pager.currentPage + 1
      }
      UIView.animateWithDuration(0.3,
        delay: 0.0,
        options: UIViewAnimationOptions.CurveEaseIn,
        animations: { () -> Void in
         
          self.collectionView.center.x += 400
        }) { (success) -> Void in
          self.collectionView.center.x -= 800
          self.reloadCollections()
          UIView.animateWithDuration(0.3,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseOut,
            animations: { () -> Void in
              self.collectionView.center.x += 400
            }) { (success) -> Void in
              println("Yay!")
              
          }
      }
    }
  }
  @IBAction func userDidPinch(sender: UIPinchGestureRecognizer) {
    self.isPinching = true
    let minWidth = screenWidth * 0.08
    let maxWidth = screenWidth * 0.8
    
    let scale = sender.scale
    
      self.collectionView.performBatchUpdates({ () -> Void in
        self.layout.itemSize = CGSize(width: self.initialSize.width * scale, height: self.initialSize.width * scale)
        if self.layout.itemSize.width < minWidth{
          self.layout.itemSize = CGSize(width: minWidth, height: minWidth)
        } else if self.layout.itemSize.width > maxWidth{
          self.layout.itemSize = CGSize(width: maxWidth, height: maxWidth)
        }
      }, completion: nil )
    

    
    if sender.state == .Ended {
      self.initialSize = layout.itemSize
      self.isPinching = false
    }

  }
}

//MARK: - ENUMS

enum GalleryType {
  case Random, PhotoAPI
}

enum CollectionType {
  case Moments, Albums, All
  
  func getCollectionType() -> PHAssetCollectionType? {
    switch self {
    case .Moments:
      return PHAssetCollectionType.Moment
    case .Albums:
      return PHAssetCollectionType.Album
    case .All:
      return nil
    }
  }
  mutating func next(){
    switch self {
    case .Moments:
      self = .Albums
    case .Albums:
      self = .All
    case .All:
      self = .Moments
    }
  }
  mutating func previous(){
    switch self {
    case .Moments:
      self = .All
    case .Albums:
      self = .Moments
    case .All:
      self = .Albums
    }
  }
  func toString() -> String{
    switch self {
    case .Moments:
      return "Moments"
    case .Albums:
      return "Albums"
    case .All:
      return "All Photos"
    }
  }
}
