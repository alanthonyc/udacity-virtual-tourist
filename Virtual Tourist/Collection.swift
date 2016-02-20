//
//  Collection.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/19/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import Foundation
import CoreData

let ENTITY_NAME_COLLECTION = "Collection"

class Collection: NSManagedObject
{
    struct Keys
    {
        static let Name = "name"
        static let Pins = "pins"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
    {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext)
    {
        let entity =  NSEntityDescription.entityForName(ENTITY_NAME_PIN, inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        name = dictionary[Keys.Name] as? String
    }
}