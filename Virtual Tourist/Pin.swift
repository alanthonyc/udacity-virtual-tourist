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
        static let Category = "category"
        static let Photos = "photos"
        static let Page = "page"
        static let Pages = "pages"
        static let PhotosForPage = "photosForPage"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?)
    {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext)
    {
        let entity =  NSEntityDescription.entityForName(ENTITY_NAME_PIN, inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        longitude = dictionary[Keys.Longitude] as? Double
        latitude = dictionary[Keys.Latitude] as? Double
        page = dictionary[Keys.Page] as? Int
        pages = dictionary[Keys.Pages] as? Int
        collection = dictionary[Keys.Collection] as? Collection
        category = dictionary[Keys.Category] as? Category
        photosForPage = dictionary[Keys.PhotosForPage] as? Int
    }
    
    func getImages()
    {
        FlickrRequestController().getImagesAroundLocation(self.latitude as! Double, lon:self.longitude as! Double, page:self.page as! Int, picsPerPage: MAX_NUMBER_OF_CELLS)
            {
                JSONResult, error in
                if let error = error {
                    print("Error pre-loading images for pin: \(error)")
                    
                } else {
                    let photosDictionary = JSONResult
                    self.pages = photosDictionary["pages"] as? NSNumber
                    let photos = photosDictionary["photo"] as! NSArray
                    self.photosForPage = photos.count
                    for pic in photos
                    {
                        self.attachPhoto(pic as! NSDictionary)
                    }
                    for photo in self.photos!
                    {
                        self.downloadPhoto(photo as! Photo)
                    }
                }
        }
    }
    
    func attachPhoto(photoDict: NSDictionary)    {
        let photoEntity = NSEntityDescription.entityForName(ENTITY_NAME_PHOTO, inManagedObjectContext: self.managedObjectContext!)
        let photo = NSManagedObject(entity: photoEntity!, insertIntoManagedObjectContext: self.managedObjectContext!) as! Photo
        
        let time = NSDate().timeIntervalSince1970
        let uniqueFilename = "\(photoDict[FLICKR_DICT_ID]!)\(time)"
        photo.setValue(photoDict[FLICKR_DICT_URLM], forKey: Photo.Keys.flickrUrl)
        photo.setValue(photoDict[FLICKR_DICT_ID], forKey: Photo.Keys.flickrId)
        
        photo.setValue(uniqueFilename, forKey: Photo.Keys.filename)
        photo.setValue(false, forKey: Photo.Keys.downloaded)
        photo.setValue(self, forKey: Photo.Keys.Pin)
    }
    
    func downloadPhoto(photo: Photo) -> Void
    {
        guard photo.flickrUrl != nil else
        {
            print("Photo Flickr url is nil.")
            return
        }
        
        if let imageData = NSData(contentsOfURL: NSURL(string: photo.flickrUrl!)!) {
            dispatch_async(dispatch_get_main_queue(),
            {
                guard photo.filename != nil else
                {
                    return
                }
                let path = pathForIdentifier(photo.filename!)
                let data = UIImagePNGRepresentation(UIImage(data: imageData)!)!
                photo.setValue(path, forKey: Photo.Keys.fileSystemUrl)
                photo.setValue(true, forKey: Photo.Keys.downloaded)
                data.writeToFile(path, atomically: true)
            })
            
        } else {
            print("Error downloading image at: \(photo.flickrUrl)")
        }
    }
}












