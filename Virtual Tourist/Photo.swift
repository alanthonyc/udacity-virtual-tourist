//
//  Photo.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 1/26/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
    
    struct Keys {
        static let Name = "name"
        static let ID = "id"
    }
    
    @NSManaged var name: String
    @NSManaged var id: NSNumber

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        name = dictionary[Keys.Name] as! String
        id = dictionary[Keys.ID] as! Int
    }
}
