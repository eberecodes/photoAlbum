//
//  galleryVC.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 08/12/2021.
//

import UIKit
import CoreData

class galleryVC: UIViewController, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    
    //TODO: debug delete functionality - check if it works on my phone
    //TODO: Check if black screen still appearing wiht image picker
    //TODO: Check if 'no photos' is still appearing when images are there
    //TODO: Disable slect/cancel button when gallery is empty (hidden)
    //TODO: Debug the chekfornophotos function
    
    var buttonStatus = "Select"
    
    @IBOutlet weak var trashButton: UIButton!
    
    @IBOutlet weak var buttonClicked: UIBarButtonItem!
    
    
    
    @IBAction func deleteButton(_ sender: Any) {
        
        let deleteConfirmation = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image from the gallery?", preferredStyle: .actionSheet)
       
        
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) -> Void in
            
            if let selectedCells = self.galleryCollection.indexPathsForSelectedItems {
                  let items = selectedCells.map { $0.item }.sorted().reversed()
                  
                  for item in items {
                      self.photosList.remove(at: item)
                  }
                  
                self.galleryCollection.deleteItems(at: selectedCells)
                self.trashButton.isEnabled = false
                }
            self.updateCoreData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {  (action: UIAlertAction) -> Void in
            print("Cancel image deletion")
        }

        deleteConfirmation.addAction(deleteAction)
        deleteConfirmation.addAction(cancelAction)

        present(deleteConfirmation, animated: true, completion: nil)
        checkForNoPhotos()
    }
    
    
    
    @IBAction func selectCancelButton(_ sender: UIButton) {
        print("Save button clicked")
        let buttonTitle = buttonClicked.title!
        print(buttonTitle)
        if buttonTitle == "Select" {
            self.buttonClicked.title = "Cancel"
            buttonStatus = "Cancel"
            sender.setTitle("Cancel", for: .normal)
            galleryCollection.allowsMultipleSelection = true
        }
        else{
            self.buttonClicked.title = "Select"
            buttonStatus = "Select"
           
            //Clear checks when select mode cancelled
            removeChecks()
           
            sender.setTitle("Select", for: .normal)
            galleryCollection.allowsMultipleSelection = false
        }
        
       
        
    }
    func removeChecks(){
        let indexPaths = galleryCollection.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = galleryCollection.cellForItem(at: indexPath) as! GalleryCollectionViewCell
            cell.checkLabel.isHidden = true
            galleryCollection.deselectItem(at: indexPath, animated: true) 
        }
        trashButton.isEnabled = false
    }
    
    var firstLoad = true
    
   // var pickImage = UIImagePickerController()
    var photosList = [UIImage]()
    var photosData = [Data]()
    
    var imageArray = [Data]()
    
    
    var selectedAlbum: Album? = nil
    
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
    
    
    //MARK: Collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
        
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! GalleryCollectionViewCell
    
       
        imageCell.galleryImage.image = photosList[indexPath.item]
        
        //if let imageView = imageCell.viewWithTag(1000) as? UIImageView {
        //       imageView.image = photosList[indexPath.item]
        //   }
        
        
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        //TODO: Check buttonStatus variable 
        print("collection view cell tapped")
        let cell = galleryCollection.cellForItem(at: indexPath) as! GalleryCollectionViewCell
       
        
        if buttonStatus == "Select" {
                trashButton.isEnabled = false
                cell.checkLabel.isHidden = true
                cell.isInSelectMode = false
                print("issue")
            } else {
                trashButton.isEnabled = true
                if cell.checkLabel.text != "✓"{
                    cell.checkLabel.text = "✓"
                    cell.checkLabel.isHighlighted = true
                }
               // cell.checkLabel.text = "✓"
               // cell.checkLabel.isHighlighted = true
                cell.isInSelectMode = true
                print("issue 2")
            }
        
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedImages = collectionView.indexPathsForSelectedItems, selectedImages.count == 0 {
               trashButton.isEnabled = false
           }
        let cell = galleryCollection.cellForItem(at: indexPath) as! GalleryCollectionViewCell
        cell.checkLabel.text = ""
    }
    
    

    
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
        
        checkForNoPhotos()
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
        self.buttonClicked.title = "Select"
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
            
            //accessing through unique ID
            let albumID = selectedAlbum?.id
            request.predicate = NSPredicate(format: "%@ IN id", albumID!)
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
        checkForNoPhotos()
       
        
    }
    
    @IBAction func save(_ sender: Any) {
        updateCoreData()
    }
    
    func updateCoreData(){
        
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
    
    func checkForNoPhotos(){
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = self.view.center
        label.center.x = self.view.center.x
        label.center.y = self.view.center.y
        
        label.textAlignment = .center
        //label.text = "no photos"
        if photosList.isEmpty
        {
            print("empty")
            label.text = "no photos"
            self.view.addSubview(label)
            buttonClicked.isEnabled = false
            //label.tag = 7
        }
        else{
            print("not empty")
            label.text = ""
            self.view.addSubview(label)
            self.view.removeFromSuperview()
            buttonClicked.isEnabled = true
            //label.isHidden = true
            //self.view.remove
            
        }
        galleryCollection.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSettings"){
            let galleryDetail = segue.destination as? settingsViewController
            galleryDetail!.selectedAlbum = selectedAlbum
            
        }
    }
    
    

    
  

}
