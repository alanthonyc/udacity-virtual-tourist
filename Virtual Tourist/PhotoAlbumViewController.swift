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
let MAX_NUMBER_OF_CELLS = 21
let PHOTO_ALBUM_VC_IDENTIFIER = "photoAlbumViewController"

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate
{
    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    
    // MARK: - Properties
    
    var pin: Pin?
    var maxPage: Int!
    var currentPage: Int!
    var insertedPhotos: [NSIndexPath]!
    var deletedPhotos: [NSIndexPath]!
    var updatedPhotos: [NSIndexPath]!
    
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
        self.noImagesLabel.alpha = 1.0
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
    
    // MARK: - Actions
    
    @IBAction func newCollectionButtonTapped()
    {
        print("button tapped")
        deletePhotoAlbum()
    }
    
    // MARK: - NSFetchedResultsController
    
    lazy var frc: NSFetchedResultsController =
    {
        let request = NSFetchRequest(entityName: ENTITY_NAME_PHOTO)
        request.predicate = NSPredicate(format: "pin == %@", self.pin!)
        request.sortDescriptors = []
        request.fetchBatchSize = MAX_NUMBER_OF_CELLS
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.moc, sectionNameKeyPath: nil, cacheName: nil)
        return controller
    } ()
    
    // MARK: - View Controller Actions
    
    // MARK: --- Download Photo Album
    
    func downloadPhotoAlbum(page: Int)
    {
//        FlickrRequestController().getImagesAroundLocation(self.pin!.latitude as! Double, lon:self.pin!.longitude as! Double, page:page, picsPerPage: MAX_NUMBER_OF_CELLS)
//        {
//            JSONResult, error in
//            if let error = error
//            {
//                print("Error downloading images for album: \(error)")
//                
//            } else {
//                let photosDictionary = JSONResult
//                let photos = photosDictionary["photo"] as! NSArray
//                self.pin!.setValue(photos.count, forKey: Pin.Keys.PhotosForPage)
//                for pic in photos {
//                    self.pin!.attachPhoto(pic as! NSDictionary, moc: self.moc)
//                }
//            }
//        }
//        let photos = self.photosStillNotDownloaded()!
//        for photo in photos
//        {
//            print("photo to download: \(photo)")
//        }
    }
    
    func deletePhotoAlbum()
    {
        for photo in self.pin!.photos!
        {
            self.moc.deleteObject(photo as! Photo)
        }
    }
    
    // MARK: - Core Data Helper
    
    lazy var moc =
    {
        CoreDataManager.sharedInstance().managedObjectContext
    } ()
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return NUMBER_OF_SECTIONS
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        let itemCount = self.frc.fetchedObjects!.count
        if itemCount > 0 {
            self.noImagesLabel.alpha = 0.0
            self.collectionView.alpha = 1.0
            return itemCount
            
        } else {
            self.noImagesLabel.alpha = 1.0
            self.collectionView.alpha = 0.0
        }
        return 0
    }
    
//    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath)
//    {
//
//    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath) as! CollectionViewCell
        configureCell(cell, indexPath: indexPath)
        return cell;
    }
    
    func configureCell(cell: CollectionViewCell, indexPath: NSIndexPath)
    {
        cell.backgroundColor = UIColor.groupTableViewBackgroundColor()
        cell.layer.cornerRadius = 4.0
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.alpha = 1.0
        cell.imageCell.layer.shadowOpacity = 0.5
        cell.imageCell.layer.shadowColor = UIColor.darkGrayColor().CGColor
        cell.imageCell.layer.shadowOffset = CGSizeMake(-2, 2)

        let photo = self.frc.objectAtIndexPath(indexPath) as! Photo
        let image = photo.image() as UIImage?
        if image != nil {
            cell.imageCell.image = image
            cell.activityIndicator.stopAnimating()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let photoToDelete = frc.objectAtIndexPath(indexPath) as! Photo
        self.pin!.photosForPage = (self.pin!.photosForPage as! Int) - 1
        self.moc.deleteObject(photoToDelete)
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController)
    {
        insertedPhotos = [NSIndexPath]()
        deletedPhotos = [NSIndexPath]()
        updatedPhotos = [NSIndexPath]()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController)
    {
        collectionView.performBatchUpdates({() -> Void in
            
            for photo in self.insertedPhotos
            {
                self.collectionView.insertItemsAtIndexPaths([photo])
            }
            
            for indexPath in self.deletedPhotos
            {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }

            for photo in self.updatedPhotos
            {
                self.collectionView.reloadItemsAtIndexPaths([photo])
            }
            
            }, completion: nil)
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?)
    {
        switch type{
            case .Insert:
                self.insertedPhotos.append(newIndexPath!)
                break
            case .Delete:
                self.deletedPhotos.append(indexPath!)
                break
            case .Update:
                self.updatedPhotos.append(indexPath!)
                break
            case .Move:
                print("Move Photo")
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
















