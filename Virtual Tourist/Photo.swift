//
//  Photo.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/16/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import Foundation
import CoreData

class Photo: NSManagedObject {
    
    struct Keys {
        static let fileSystemUrl = "fileSystemUrl"
        static let flickrUrl = "flickrUrl"
        static let Pin = "pin"
    }

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        fileSystemUrl = dictionary[Keys.fileSystemUrl] as? String
        flickrUrl = dictionary[Keys.flickrUrl] as? String
        pin = dictionary[Keys.Pin] as? Pin
    }
}
