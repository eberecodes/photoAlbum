//
//  Album.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 11/12/2021.
//

import CoreData

@objc(Album)

class Album: NSManagedObject{
    @NSManaged var id: NSNumber!
    @NSManaged var title: String!
    @NSManaged var deletedDate: Date? //was changed from just date
    @NSManaged var photoGallery: Data?
    
}
