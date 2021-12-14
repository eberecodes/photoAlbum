//
//  galleryVC.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 08/12/2021.
//

import UIKit
import CoreData

class galleryVC: UIViewController, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {

    //TODO: Need to distinguish all the differnt albums from their individual galleries
    
    var firstLoad = true
    
   // var pickImage = UIImagePickerController()
    var photosList = [UIImage]()
    var photosData = [Data]()
    
    var imageArray = [Data]()
    
    func convertPhotosToData(photoList: [UIImage]) -> [Data] {
      var photosDataList = [Data]()
    
      for photo in photoList{
          if (photo.pngData() != nil){
              photosDataList.append(photo.pngData()!)
              print("not nil")
          }
          
      }
        
      return photosDataList
    }
    
    func convertDataToPhotos(imageDataArray: [Data]) -> [UIImage] {
      var myImagesArray = [UIImage]()
      print("test")

      for data in imageDataArray{
          if (UIImage(data: data) != nil) {
             myImagesArray.append(UIImage(data: data)!)
             print("not nil")
         }
      }
      
      return myImagesArray
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
    
        
        if let imageView = imageCell.viewWithTag(1000) as? UIImageView {
               imageView.image = photosList[indexPath.item]
           }
        
        return imageCell
    }
    
    
    var selectedAlbum: Album? = nil
    
    
    @IBAction func uploadButton(_ sender: Any) {
        
        /*if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){

                    pickImage.delegate = self
                    //pickImage.sourceType = .savedPhotosAlbum
                    pickImage.allowsEditing = false

                }*/
        let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.delegate = self
            present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

            dismiss(animated: true)

            photosList.insert(image, at: 0)
            galleryCollection.reloadData()
       }
    
    
    
    @IBOutlet weak var galleryCollection: UICollectionView!
    
    @IBAction func settingsButton(_ sender: Any) {
        performSegue(withIdentifier: "toSettings", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Gallery"
        //title = albumList[indexPath]
        // Do any additional setup after loading the view.
        if (selectedAlbum != nil){
            title = selectedAlbum?.title
            //will need to add image eventually too
        }
        
        if (firstLoad){
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
            
            
            do {
                let result:[NSManagedObject] = try context.fetch(request) as! [NSManagedObject]
              for r in result{
                  if(r.value(forKey: "photoGallery") == nil){
                      break
                  }
                  else{
                      photosData.append(r.value(forKey: "photoGallery") as! Data)
                  }
              }
            }  catch{
                print("failed to fetch")
            }
            //var imageArray = [Data]()
            
            for imageData in photosData {
                var dataArray = [Data]()
                do {
                  dataArray = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: imageData) as! [Data]
                    imageArray.append(contentsOf: dataArray)
                    
                } catch {
                  print("could not unarchive array: \(error)")
                }
            }
            //should protect against issues
            photosList = convertDataToPhotos(imageDataArray: imageArray)
            
            
            
            
        }
        
     
    }
    
    @IBAction func save(_ sender: Any) {
        let photosDataList = convertPhotosToData(photoList: photosList)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        //let entity = NSEntityDescription.entity(forEntityName: "Album", in: context)
        
        
        //let photo = NSManagedObject(entity: entity!, insertInto: context)
        
        
        var photos: Data?
        do {
            photos = try NSKeyedArchiver.archivedData(withRootObject: photosDataList, requiringSecureCoding: true)
        } catch {
            print("error")
        }
        selectedAlbum?.photoGallery = photos
        //photo.setValue(photos, forKeyPath: "photoGallery")

        do {
          try context.save()
        } catch{
           print("Error saving context")
        }
        
        
    }
    

}
