//
//  Filter.swift
//  Photo Filters
//
//  Created by Cameron Klein on 10/14/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var readableName: String
    @NSManaged var value1: String
    @NSManaged var value2: String
    @NSManaged var value1Default: Float
    @NSManaged var value2Default: Float
  
}