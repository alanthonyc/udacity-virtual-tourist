//
//  Pin+CoreDataProperties.swift
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

extension Pin
{
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var photos: NSSet?
    @NSManaged var page: NSNumber?
    @NSManaged var collection: Collection?
    @NSManaged var photosForPage: NSNumber?
}
