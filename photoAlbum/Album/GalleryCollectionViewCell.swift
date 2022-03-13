//
//  GalleryCollectionViewCell.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 21/02/2022.
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
