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

let NUMBER_OF_SECTIONS = 1
let NUMBER_OF_CELLS = 21

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource
{
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var coordinates: CLLocationCoordinate2D!
    var pinAnnotation: MKPointAnnotation?
    var maxPage: Int!
    var currentPage: Int!
    var tempImage: UIImage?
    var pin: Pin?
    
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
        self.pinAnnotation = point
        self.maxPage = 1
        self.currentPage = 1
        
        // TODO: delete
        let tempUrl = NSURL(string:"https://farm3.staticflickr.com/2670/4104750510_ca07dc7255.jpg")
        let tempImageData = NSData(contentsOfURL: tempUrl!)
        self.tempImage = UIImage(data: tempImageData!)
    }
    
    override func viewWillAppear(animated: Bool)
    {
        if pin?.photos!.count > 0 {
            print("photos found")
            
        } else {
            loadImages(1)
        }
    }
    
    override func viewDidAppear(animated: Bool)
    {
        let region = MKCoordinateRegionMakeWithDistance(self.coordinates, 1600, 1600);
        mapView.setCenterCoordinate(self.coordinates, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    func loadImages(onPage: Int)
    {
        print("loading images...")
        FlickrRequestController().getImagesAroundLocation(self.coordinates.latitude, lon:self.coordinates.longitude, page:self.currentPage, picsPerPage: NUMBER_OF_CELLS) {
            JSONResult, error in
            if let error = error {
                print("Error: \(error)")
                
            } else {
                let photosDictionary = JSONResult
                let photos = photosDictionary["photo"] as! NSArray
                print("Pics: \(photos.count)")
                for pic in photos {
                    print("Pic id: \(pic["id"]), url:\(pic["url_m"])")
                }
                let pic1 = photos[1]
                let photoUrl = pic1["url_m"] as! String
                FlickrRequestController().getImage(photoUrl, completionHandler: {
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
    
    // MARK: Core Data
    
    lazy var moc =
    {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return NUMBER_OF_SECTIONS
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return NUMBER_OF_CELLS
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.cornerRadius = 4.0
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.alpha = 1.0
        return cell;
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
