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

struct Keys
{
    static let Longitude = "longitude"
    static let Latitude = "latitude"
    static let Photos = "photos"
    static let Page = "page"
}

class Pin: NSManagedObject
{
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
    {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext)
    {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        longitude = dictionary[Keys.Longitude] as! Double
        latitude = dictionary[Keys.Latitude] as! Double
        page = dictionary[Keys.Page] as! Int
    }
    
    func attachPhoto(photoDict: NSDictionary, moc: NSManagedObjectContext)
    {
        let photoEntity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: moc)
        let photo = NSManagedObject(entity: photoEntity!, insertIntoManagedObjectContext: moc) as! Photo
        photo.setValue(photoDict["url_m"], forKey: "flickrUrl")
        photo.setValue(photoDict["id"], forKey: "flickrId")
        photo.setValue(photoDict["id"], forKey: "filename")
        photo.setValue(self, forKey: "pin")
        if let imageData = NSData(contentsOfURL: NSURL(string: photo.flickrUrl!)!) {
            dispatch_async(dispatch_get_main_queue(), {
                let path = pathForIdentifier(photo.flickrId!)
                let data = UIImagePNGRepresentation(UIImage(data: imageData)!)!
                photo.setValue(path, forKey: "fileSystemUrl")
                data.writeToFile(path, atomically: true)
            })
            
        } else {
            print("Error downloading image at: \(photo.flickrUrl)")
        }
    }
}












