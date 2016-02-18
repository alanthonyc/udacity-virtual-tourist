//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/13/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import UIKit
import CoreData
import MapKit

private let reuseId = "CollectionViewCell"

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {

    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var coordinates: CLLocationCoordinate2D!
    var pin: MKPointAnnotation?
    var maxPage: Int?
    var image: UIImage?
    
    // MARK: - Housekeeping

    override func awakeFromNib()
    {
        super.awakeFromNib()
        self.coordinates = CLLocationCoordinate2DMake(0, 0)
    }
    
    override func viewDidLoad()
    {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        
        let point = MKPointAnnotation.init()
        point.coordinate = self.coordinates
        self.mapView.addAnnotation(point)
        self.pin = point
        self.maxPage = 1
        
        let tempUrl = NSURL(string:"https://farm3.staticflickr.com/2670/4104750510_ca07dc7255.jpg")
        let imageData = NSData(contentsOfURL: tempUrl!)
        self.image = UIImage(data: imageData!)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        let region = MKCoordinateRegionMakeWithDistance(self.coordinates, 1600, 1600);
        mapView.setCenterCoordinate(self.coordinates, animated: true)
        mapView.setRegion(region, animated: true)
        let p = FlickrRequestController()
        p.getImagesAroundLocation(self.coordinates.latitude, lon:self.coordinates.longitude, page:1) {
            JSONResult, error in
            if let error = error {
                print("Error: \(error)")
                
            } else { // success
                
                let photosDictionary = JSONResult
                let photos = photosDictionary["photo"] as! NSArray
                print("Pics: \(photos.count)")
                for pic in photos {
                    print("Pic id: \(pic["id"]), url:\(pic["url_m"])")
                }
                let pic1 = photos[1]
                let photoUrl = pic1["url_m"] as! String
                p.getImage(photoUrl, completionHandler: {
                    imageData, error in
                    if let error = error {
                        print("Error retrieving image: \(error)")
                        
                    } else {
                        let photo = imageData as! NSData
                        _ =  UIImage(data: photo)
                    }
                })
            }
        }
    }
    
    func loadImages(onPage: Int) {
        
    }
    
    // MARK: Core Data
    
    lazy var moc = {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    func createPhotoEntity() {
        let photoEntity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: moc)
        let photo = NSManagedObject(entity: photoEntity!, insertIntoManagedObjectContext: moc)
        photo.setValue("test://this_is_a_test_url", forKey: "fileSystemUrl")
        photo.setValue("test://this_is_a_test_url", forKey: "flickrUrl")
        photo.setValue(self.pin, forKey: "pin")
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 21
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.cornerRadius = 4.0
        if (self.image != nil) {
            cell.imageCell.image = self.image!
        }
        return cell;
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
