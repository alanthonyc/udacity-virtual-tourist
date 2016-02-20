//
//  Pin.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/16/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let ENTITY_NAME_PIN = "Pin"

class Pin: NSManagedObject
{
    struct Keys
    {
        static let Longitude = "longitude"
        static let Latitude = "latitude"
        static let Collection = "collection"
        static let Photos = "photos"
        static let Page = "page"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
    {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext)
    {
        let entity =  NSEntityDescription.entityForName(ENTITY_NAME_PIN, inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        longitude = dictionary[Keys.Longitude] as! Double
        latitude = dictionary[Keys.Latitude] as! Double
        page = dictionary[Keys.Page] as! Int
    }
    
    func attachPhoto(photoDict: NSDictionary, moc: NSManagedObjectContext)
    {
        let photoEntity = NSEntityDescription.entityForName(ENTITY_NAME_PHOTO, inManagedObjectContext: moc)
        let photo = NSManagedObject(entity: photoEntity!, insertIntoManagedObjectContext: moc) as! Photo
        photo.setValue(photoDict[FLICKR_DICT_URLM], forKey: Photo.Keys.flickrUrl)
        photo.setValue(photoDict[FLICKR_DICT_ID], forKey: Photo.Keys.flickrId)
        photo.setValue(photoDict[FLICKR_DICT_ID], forKey: Photo.Keys.filename)
        photo.setValue(self, forKey: Photo.Keys.Pin)
        if let imageData = NSData(contentsOfURL: NSURL(string: photo.flickrUrl!)!) {
            dispatch_async(dispatch_get_main_queue(), {
                let path = pathForIdentifier(photo.flickrId!)
                let data = UIImagePNGRepresentation(UIImage(data: imageData)!)!
                photo.setValue(path, forKey: Photo.Keys.fileSystemUrl)
                data.writeToFile(path, atomically: true)
            })
            
        } else {
            print("Error downloading image at: \(photo.flickrUrl)")
        }
    }
}












