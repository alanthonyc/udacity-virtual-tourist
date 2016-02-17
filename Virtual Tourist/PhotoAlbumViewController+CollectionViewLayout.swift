//
//  PhotoAlbumViewController+CollectionViewLayout.swift
//  Virtual Tourist
//
//  Created by A. Anthony Castillo on 2/17/16.
//  Copyright © 2016 Alon Consulting. All rights reserved.
//

import Foundation
import UIKit

private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 50.0, right: 10.0)

extension PhotoAlbumViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
}