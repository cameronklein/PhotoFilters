//
//  GalleryViewController.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit

protocol MySampleDelegate {
  func didTapOnPicture(image: UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  @IBOutlet weak var collectionView: UICollectionView!
  let imageQueue = NSOperationQueue()
  var adjectiveArray = [String]()
  var nounArray = [String]()
  
  var delegate : MySampleDelegate?
  
  // MARK - Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    adjectiveArray = ["Angry", "Voracious", "Silly", "Loud", "False", "Naive", "Spiteful", "Heavenly", "Curved"]
    nounArray = ["Mass", "Damage", "Reward", "Growth", "Act", "Effect", "Rhythm", "Verse", "Plant"]
    
    collectionView.registerNib(UINib(nibName: "HeaderView", bundle: NSBundle.mainBundle()), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "HEADER")
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()

  }
  
  // MARK - UICollectionView Data Source
  
  func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 6
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 9
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    
    cell.userInteractionEnabled = false
    cell.imageView.image = nil
    cell.spinningWheel.startAnimating()
    var urlString : String!
    
    switch indexPath.section{
    case 0:
      urlString = "http://lorempixel.com/400/400/animals"
    case 1:
      urlString = "http://lorempixel.com/400/400/food"
    case 2:
      urlString = "http://lorempixel.com/400/400/sports"
    case 3:
      urlString = "http://lorempixel.com/400/400/nature"
    case 4:
      urlString = "http://lorempixel.com/400/400/people"
    default:
      urlString = "http://lorempixel.com/400/400/city"
    }
    let url = NSURL(string: urlString)
    //if cell.isLoading == false {
      imageQueue.addOperationWithBlock { () -> Void in
        cell.isLoading = true
        let data = NSData(contentsOfURL: url)
        let image = UIImage(data: data)
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          cell.imageView.image = image
          cell.spinningWheel.stopAnimating()
          cell.userInteractionEnabled = true
          cell.isLoading = false
        })
      //}
    }
    
    var randomNumber1: Int = Int(arc4random()) % adjectiveArray.count
    var randomNumber2: Int = Int(arc4random()) % adjectiveArray.count
    let randomAdj = adjectiveArray[randomNumber1]
    let randomNou = nounArray[randomNumber2]
    cell.titleLabel.text = randomAdj + " " + randomNou
    
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    
      println("Called!")
      let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "HEADER", forIndexPath: indexPath) as HeaderView
    
    switch indexPath.section{
    case 0:
      view.label.text = "Animals!"
    case 1:
      view.label.text = "Food!"
    case 2:
      view.label.text = "Sports!"
    case 3:
      view.label.text = "Nature!"
    case 4:
      view.label.text = "People!"
    default:
      view.label.text = "City!"
    }

    view.view.clipsToBounds = true
    view.view.layer.cornerRadius = 10
      return view
    
  }
  
  // MARK - UICollectionView Delegate
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    println("Did Select")
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as GalleryCell
    delegate?.didTapOnPicture(cell.imageView.image!)
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func collectionView(collectionView: UICollectionView, willDisplayCell cell: GalleryCell, forItemAtIndexPath indexPath: NSIndexPath) {
    cell.imageView.image = nil
  }
  
  // MARK - Helper Methods
  
  @IBAction func cancelPressed(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
  
}
