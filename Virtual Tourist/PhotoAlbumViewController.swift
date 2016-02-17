//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/13/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import UIKit
import MapKit

private let reuseId = "CollectionViewCell"

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource {

    // MARK: - IB Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    var coordinates: CLLocationCoordinate2D!
    
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
        self.collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier:reuseId)
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
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
                //error handling
                print("Error: \(error)")
                
            } else {
                // success
                // i.e. update view controller here, e.g. from favorite actors:
//                if let moviesDictionaries = JSONResult.valueForKey("cast") as? [[String : AnyObject]] {
//                    
//                    // Parse the array of movies dictionaries
//                    _ = moviesDictionaries.map() { (dictionary: [String : AnyObject]) -> Movie in
//                        let movie = Movie(dictionary: dictionary, context: self.sharedContext)
//                        
//                        movie.actor = self.actor
//                        
//                        return movie
//                    }
//                    
//                    // Update the table on the main thread
//                    dispatch_async(dispatch_get_main_queue()) {
//                        self.tableView.reloadData()
//                    }
//                    
//                    // Save the context
//                    self.saveContext()
            }
        }
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
        let cell = (self.collectionView?.dequeueReusableCellWithReuseIdentifier(reuseId, forIndexPath: indexPath))!
        cell.backgroundColor = .redColor()
        cell.layer.cornerRadius = 4.0
        return cell;
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
