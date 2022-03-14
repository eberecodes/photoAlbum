//
//  galleryVC.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 08/12/2021.
//

import UIKit
import CoreData

class galleryVC: UIViewController, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    
    //Stores the status of the button (select or cancel mode)
    var buttonStatus = "Select"
    
    //Outlets from storyboard (UI)
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var buttonClicked: UIBarButtonItem!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    
    ///Delete button action function, confirms whether user wants to delete images and performs actions based on this
    @IBAction func deleteButton(_ sender: Any) {
        
        //Alert controller for delete confirmation
        let deleteConfirmation = UIAlertController(title: "Delete Image", message: "Are you sure you want to delete this image from the gallery?", preferredStyle: .actionSheet)
       
        //TODO: check if I need these as variables
        let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) -> Void in
            self.delete()
           
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {  (action: UIAlertAction) -> Void in
            print("Cancel image deletion")
        }

        deleteConfirmation.addAction(deleteAction)
        deleteConfirmation.addAction(cancelAction)

        present(deleteConfirmation, animated: true, completion: nil)
      
        
    }
    
    
    ///Function for deleting images in the collection view
    func delete(){
        if let selectedCells = galleryCollection.indexPathsForSelectedItems {
              let items = selectedCells.map { $0.item }.sorted().reversed()
              
              for item in items {
                  photosList.remove(at: item)
              }
              
            galleryCollection.deleteItems(at: selectedCells)
            trashButton.isEnabled = false
            }
       
        //Update core data, replaces the olde photoList array with the new one
        updateCoreData()
        
        //Check for no photos again, in case all images have been deleted
        checkForNoPhotos()
        
        //Change out of select mode
        selectCancelButton(selectButton)
    }
    
    ///Action fucntion that performs action when select / cancel is clicked
    @IBAction func selectCancelButton(_ sender: UIButton) {
        print("Save button clicked")
        let buttonTitle = buttonClicked.title!

        if (buttonTitle == "Select") {
            self.buttonClicked.title = "Cancel"
            buttonStatus = "Cancel"
            sender.setTitle("Cancel", for: .normal)
            galleryCollection.allowsMultipleSelection = true
        }
        else {
            self.buttonClicked.title = "Select"
            buttonStatus = "Select"
           
            //Clear checks when select mode cancelled
            removeChecks()
           
            sender.setTitle("Select", for: .normal)
            galleryCollection.allowsMultipleSelection = false
        }
        
        
    }
    
    
    @IBOutlet weak var moreButton: UIButton!
    
    ///Clears all the checks from image views
    func removeChecks(){
        let indexPaths = galleryCollection.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = galleryCollection.cellForItem(at: indexPath) as! GalleryCollectionViewCell
            cell.checkLabel.isHidden = true
            galleryCollection.deselectItem(at: indexPath, animated: true) 
        }
        trashButton.isEnabled = false
    }
    
    //variable that allows you to only load data from core data when it's the first time the view has been loaded
    var firstLoad = true
    
    //Array of all the images
    var photosList = [UIImage]()
    
    //The photoList as Data format
    var photosData = [Data]()
    var imageArray = [Data]()
    
    //The current album which has been selected from albumViewController
    var selectedAlbum: Album? = nil
    
    var label: UILabel!
    
    ///Function converts the photos from UIImage to Data so they can be stored in coredata
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
    
    ///Function converts the data from Data to UImage so it can be presented on the screen
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
        checkForNoPhotos()
        return photosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! GalleryCollectionViewCell
    
        //Update image cell with retrieved image from photoList (core data)
        imageCell.galleryImage.image = photosList[indexPath.item]
        
        
        return imageCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        print("collection view cell tapped")
        let galleryCell = galleryCollection.cellForItem(at: indexPath) as! GalleryCollectionViewCell
       
        //When select button hasn't been clicked
        if buttonStatus == "Select" {
                trashButton.isEnabled = false //disable the trash button
                galleryCell.checkLabel.isHidden = true
                galleryCell.isInSelectMode = false
            }
        
        //When select button has been clicked
        else {
            trashButton.isEnabled = true //enable trash button
            
            //Add check mark to view
            if (galleryCell.checkLabel.text != "✓") {
                galleryCell.checkLabel.text = "✓"
                galleryCell.checkLabel.textColor = .systemBackground
                galleryCell.checkLabel.isHighlighted = true
            }

            galleryCell.isInSelectMode = true
        }
        
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let selectedImages = collectionView.indexPathsForSelectedItems, selectedImages.count == 0 {
               trashButton.isEnabled = false
           }
        let cell = galleryCollection.cellForItem(at: indexPath) as! GalleryCollectionViewCell
        cell.checkLabel.text = ""
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

            dismiss(animated: true)

            photosList.insert(image, at: 0)
            galleryCollection.reloadData()
            updateCoreData()

       }
    
    
    
    @IBOutlet weak var galleryCollection: UICollectionView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonClicked.title = "Select"
        title = "Gallery"
        
        galleryCollection.backgroundColor = UIColor.clear
        
        if (selectedAlbum != nil){
            title = selectedAlbum?.title
            
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
            photosList = convertDataToPhotos(imageDataArray: imageArray)
            
        }
        
        
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        label.center = self.view.center
        label.center.x = self.view.center.x
        label.center.y = self.view.center.y
        
        label.textAlignment = .center
        
        label.text = "no photos"
        label.textColor = .systemGray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(label)
        
        checkForNoPhotos()
        
        setUpMenu()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("view did appear")
        
        
        checkForNoPhotos()

    }
  
    
    func setUpMenu(){
        let addAction = UIAction(title: "Upload Photos", handler: { (action: UIAction)
            -> Void in
            
            let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.delegate = self
            self.present(picker, animated: true)
        })
        
        let settingsAction = UIAction(title: "Album Settings", handler: { (action: UIAction)
            -> Void in
            
            self.performSegue(withIdentifier: "toSettings", sender: nil)
        })
        
        //Update album name
        let nameAction = UIAction(title: "Change Album Name", handler: { (action: UIAction)
            -> Void in
            
            //Alert prompting user to change password in text field
            let changeAlert = UIAlertController(title: "Change Album Name", message: "Update the name of your album", preferredStyle: .alert)
            
            changeAlert.addTextField { (textField) in
                textField.text = ""
                textField.placeholder = "New album name"
            }
            
            changeAlert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak changeAlert] (_) in
                let textField = changeAlert!.textFields![0]
                
                //Save changes to core data
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                
                //Changing to title to the text entered from textfield
                self.selectedAlbum?.title = textField.text
                
                do {
                    try context.save()
                }
                
                catch {
                    print("Error saving context")
                }
                
                //Update Navigation Bar title too
                self.title = textField.text
            }))
            
            
            changeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Close alert")
          }))
            
            self.present(changeAlert, animated: true, completion: nil)
        })
        
        let menuItem = UIMenu(title: "", options: .displayInline, children: [addAction, nameAction, settingsAction])
        
        moreButton.menu = menuItem
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

        do {
          try context.save()
        } catch {
           print("Error saving context")
        }
        
        
    }
    
    //Checks if there are no photos and alters labels based on this
    func checkForNoPhotos(){
        
        let photoCount = photosList.count
 
        if photosList.isEmpty
        {
            print("empty")

            label.isHidden = false
            buttonClicked.isEnabled = false

            photoCountLabel.isHidden = true
        }
        else{
            print("not empty")
            
            label.isHidden = true
            buttonClicked.isEnabled = true
            if photoCount>1 {
                photoCountLabel.text = "\(photoCount) Photos"
            }
            else{
                photoCountLabel.text = "\(photoCount) Photo"
            }
            photoCountLabel.isHidden = false
            
        }
        galleryCollection.reloadData()
        
    }
    
    //MARK: Preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSettings"){
            let galleryDetail = segue.destination as? settingsViewController
            galleryDetail!.selectedAlbum = selectedAlbum
            
        }
    }
    
    

    
  

}
