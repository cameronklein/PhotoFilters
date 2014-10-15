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
  func didTapOnPicture(image: UIImage, frame: CGRect?)
}

enum GalleryType {
  case Random, PhotoAPI
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  let imageQueue = NSOperationQueue()
  var adjectiveArray = [String]()
  var nounArray = [String]()
  var backgroundImage : UIImage!
  var type : GalleryType = .Random
  
  var assetFetchResults: PHFetchResult!
  var assetCollection: PHAssetCollection!
  var imageManager: PHCachingImageManager!
  var assetCellSize: CGSize!
  
  var delegate : GalleryDelegate?
  
  // MARK - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER")
    
    switch type{
      
      case .Random:
        
        adjectiveArray = ["Angry", "Voracious", "Silly", "Loud", "False", "Naive", "Spiteful", "Heavenly", "Curved"]
        nounArray = ["Mass", "Damage", "Reward", "Growth", "Act", "Effect", "Rhythm", "Verse", "Plant"]
        
      case .PhotoAPI:
        
        self.imageManager = PHCachingImageManager()
        self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
        
        var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        var cellSize = flowLayout.itemSize
        
        self.assetCellSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
      
    }
    
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewDidAppear(animated: Bool) {
    self.view.backgroundColor = UIColor(patternImage: backgroundImage)
  }
  
  // MARK - UICollectionView Data Source
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    switch type {
    case .Random:
      return 6
    case .PhotoAPI:
      return 1
    }
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch type {
    case .Random:
      return 6
    case .PhotoAPI:
      return assetFetchResults.count
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
    
    let categories = ["animals", "food" ,"sports" ,"nature", "people", "city"]
    view.label.text = categories[indexPath.section]

    return view
  }
  
  // MARK - UICollectionView Delegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    println("Did Select")
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as GalleryCell
    delegate?.didTapOnPicture(cell.imageView.image!, frame: cell.frame)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: GalleryCell, forItemAtIndexPath indexPath: NSIndexPath) {
    cell.imageView.image = nil
  }
  
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
    var asset = self.assetFetchResults[indexPath.row] as PHAsset
    
    self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
      completionHandler(image)
    }
  }
  
  // MARK - IBAction
  
  @IBAction func cancelPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
