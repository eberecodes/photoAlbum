//
//  GalleryCollectionViewCell.swift
//  photoAlbum
//


import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var checkLabel: UILabel!
    
    @IBOutlet weak var galleryImage: UIImageView!
    

    var isInSelectMode: Bool = false {
        didSet {
            checkLabel.isHidden = !isInSelectMode
        }
    }

   
}
