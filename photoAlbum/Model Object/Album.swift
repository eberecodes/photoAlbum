//
//  Album.swift
//  photoAlbum
//


import CoreData

@objc(Album)

class Album: NSManagedObject{
    @NSManaged var id: NSNumber!
    @NSManaged var title: String!
    @NSManaged var photoGallery: Data?
    @NSManaged var lockStatus: String!
}
