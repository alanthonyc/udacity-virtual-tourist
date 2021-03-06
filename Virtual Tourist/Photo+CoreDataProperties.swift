//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/16/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo
{
    @NSManaged var fileSystemUrl: String?
    @NSManaged var flickrUrl: String?
    @NSManaged var pin: Pin?
    @NSManaged var flickrId: String?
    @NSManaged var filename: String?
    @NSManaged var downloaded: NSNumber? // boolean
}
