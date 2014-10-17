//
//  GalleryCell.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/13/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import UIKit
import Photos

class GalleryCell: UICollectionViewCell {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var spinningWheel: UIActivityIndicatorView!
  
  var isLoading = false
  var hasSetMotion = false
}
