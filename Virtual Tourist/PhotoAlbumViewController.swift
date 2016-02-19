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

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate
{
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var pin: Pin?
    var maxPage: Int!
    var currentPage: Int!
    
    // MARK: - Housekeeping

    override func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func viewDidLoad()
    {
        configureCollectionView()
        configureMapAnnotation()
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch {
            print("Error performing fetch.")
        }
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
        let coordinates = CLLocationCoordinate2DMake(self.pin!.latitude as! Double, self.pin!.longitude as! Double)
        let region = MKCoordinateRegionMakeWithDistance(coordinates, 1600, 1600);
        mapView.setCenterCoordinate(coordinates, animated: true)
        mapView.setRegion(region, animated: true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: --- View Configuration
    
    func configureCollectionView()
    {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        self.maxPage = 1
        self.currentPage = 1
    }
    
    func configureMapAnnotation()
    {
        let point = MKPointAnnotation.init()
        point.coordinate = CLLocationCoordinate2DMake(self.pin!.latitude as! Double, self.pin!.longitude as! Double)
        self.mapView.addAnnotation(point)
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var frc: NSFetchedResultsController =
    {
        let request = NSFetchRequest(entityName: "Photo")
        request.predicate = NSPredicate(format: "pin == %@", self.pin!)
        request.sortDescriptors = []
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    } ()
    
    // ...
    
    func loadImages(onPage: Int)
    {
        print("loading images...")
        FlickrRequestController().getImagesAroundLocation(pin!.latitude as! Double, lon:pin!.longitude as! Double, page:self.currentPage, picsPerPage: NUMBER_OF_CELLS) {
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
        configureCell(cell, indexPath: indexPath)
        return cell;
    }
    
    func configureCell(cell: CollectionViewCell, indexPath: NSIndexPath)
    {
        cell.backgroundColor = UIColor.lightGrayColor()
        cell.layer.cornerRadius = 4.0
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.alpha = 1.0
        
        let photo = self.frc.objectAtIndexPath(indexPath) as! Photo
        
        if photo.fileSystemUrl == nil || photo.fileSystemUrl == "" {
            print("Photo not downloaded (yet?).")
            // download photo
            
        } else if photo.fileSystemUrl != nil {
            var documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            documentsPath.appendContentsOf("/\(photo.filename!)")
            let data = NSData(contentsOfFile: documentsPath)
            let image = UIImage(data: data!)
            cell.imageCell.image = image
            cell.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
//        self.collectionView... (get ready for updates)
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
//        collectionView.performBatchUpdates({() -> Void in
//            
//            for indexPath in self.insertedIndexPaths {
//                self.collectionView.insertItemsAtIndexPaths([indexPath])
//            }
//            
//            for indexPath in self.deletedIndexPaths {
//                self.collectionView.deleteItemsAtIndexPaths([indexPath])
//            }
//            
//            for indexPath in self.updatedIndexPaths {
//                self.collectionView.reloadItemsAtIndexPaths([indexPath])
//            }
//            
//            }, completion: nil)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch type{
            case .Insert:
                print("Insert an item.")
                print("indexPath: \(indexPath) newIndexPath: \(newIndexPath)")
                break
            case .Delete:
                print("Delete an item.")
                break
            case .Update:
                print("Update an item.")
                break
            case .Move:
                print("Move an item. We don't expect to see this in this app.")
                break
        }
    }
    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType)
//    {
//    
//    }
    
//    func controller(controller: NSFetchedResultsController, sectionIndexTitleForSectionName sectionName: String) -> String?
//    {
//
//    }
}
















