//
//  galleryVC.swift
//  photoAlbum


import UIKit
import CoreData
import Vision

class galleryVC: UIViewController, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    
    //Stores the status of the button (select or cancel mode)
    private var buttonStatus = "Select"
    
    //So the gallery can be filtered
    var filteredPhotosList:[UIImage]!
    
    //Outlets from storyboard (UI)
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var buttonClicked: UIBarButtonItem!
    @IBOutlet weak var photoCountLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton! //check if I need this
   
    //Array of all the images
    private var photosList = [UIImage]()
    
    //The photoList as Data format
    private var photosData = [Data]()
    private var imageArray = [Data]()
    
    //The current album which has been selected from albumViewController
    var selectedAlbum: Album? = nil
    
    //no photos labeL for UI
    private var label: UILabel!
    
    
    //MARK: Delete Photo
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
    
    
    ///Action function that performs action when select / cancel is clicked
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
    
    //UI IBOutlet linking more button
    @IBOutlet weak var moreButton: UIButton!
    
    ///Function for deleting images in the collection view
    func delete(){
        if let selectedCells = galleryCollection.indexPathsForSelectedItems {
              let items = selectedCells.map { $0.item }.sorted().reversed()
              
              for item in items {
                  photosList.remove(at: item)
              }
            filteredPhotosList = photosList  //update list
            
            galleryCollection.deleteItems(at: selectedCells)
            trashButton.isEnabled = false
            }
       
        //Update core data, replaces the olde photoList array with the new one
        updateCoreData()
        
        //Check for no photos again, in case all images have been deleted
        checkForPhotos()
        
        //Change out of select mode
        selectCancelButton(selectButton)
    }
    
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
    

    
    //MARK: Collection View
    
    //Outlet for gallery collection view
    @IBOutlet weak var galleryCollection: UICollectionView!
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        checkForPhotos()
        //return photosList.count
        return filteredPhotosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
 
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! GalleryCollectionViewCell
        
        //Update image cell with retrieved image from filteredPhotoList (core data)
        imageCell.galleryImage.image = filteredPhotosList[indexPath.item]
        
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
    
    ///Collection view function that tracks when user deselects item
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //If no images have been selected user can't delete anything
        if let selectedImages = collectionView.indexPathsForSelectedItems, selectedImages.count == 0 {
               trashButton.isEnabled = false
           }
        let cell = galleryCollection.cellForItem(at: indexPath) as! GalleryCollectionViewCell
        cell.checkLabel.text = "" //no check label as nothing has been selected
    }
    
    ///Function takes the image the user select and adds it to the gallery
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //The image they've selected
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        dismiss(animated: true)
        
        //insert image into collection view by first adding it to phot list
        photosList.insert(image, at: 0)
        self.filteredPhotosList = photosList //update the filtered list
        
        //Update rhe gallery collection so the new image can be seen
        galleryCollection.reloadData()
        updateCoreData()

    }
    
    //MARK: View Loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        self.buttonClicked.title = "Select" //initialise to select
        title = "Gallery"
        
        //UI
        galleryCollection.backgroundColor = UIColor.clear
        
        //Set navigation bar title
        if (selectedAlbum != nil){
            title = selectedAlbum?.title
        }
        
        //Checks something is stored in photoGallery
        if (selectedAlbum?.photoGallery != nil){
            photosData.append((selectedAlbum?.photoGallery)!)
        }
            
        //Decode image data
        for imageData in photosData {
            var dataArray = [Data]()
            do {
                dataArray = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: imageData) as! [Data]
                imageArray.append(contentsOf: dataArray)
                    
            } catch {
                print("Could not unarchive array: \(error)")
            }
        }
        //Send image array to be converted to UIImage
        photosList = convertDataToPhotos(imageDataArray: imageArray)
            
        //Copy contents of photo list to filtered photo list
        filteredPhotosList = photosList

        
        //Create label for UI
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 20))
        label.center = self.view.center //place label at center of the page
        label.textAlignment = .center
        label.text = "No Photos"
        label.textColor = .systemGray
        label.font = UIFont.boldSystemFont(ofSize: 20)
        self.view.addSubview(label) //add to subview
        
        checkForPhotos() //checks for photos so labels can be accurate
        setUpMenu() //sets up menu
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkForPhotos() //checks for photos so labels can be accurate
    }
  
    //MARK: More Menu
    
    //This function sets up the menu for the more button
    func setUpMenu(){
        //Menu option action created for uploading photos
        let addAction = UIAction(title: "Upload Photos", handler: { (action: UIAction)
            -> Void in
            
            let picker = UIImagePickerController()
                picker.allowsEditing = true
                picker.delegate = self
            self.present(picker, animated: true)
        })
        
        //Menu option action created for navigating to settings page
        let settingsAction = UIAction(title: "Album Settings", handler: { (action: UIAction)
            -> Void in
            
            self.performSegue(withIdentifier: "toSettings", sender: nil)
        })
        
        //Menu option action created for updating album name
        let nameAction = UIAction(title: "Change Album Name", handler: { (action: UIAction)
            -> Void in
            
            //Alert prompting user to change password in text field
            let changeAlert = UIAlertController(title: "Change Album Name", message: "Update the name of your album", preferredStyle: .alert)
            
            //setting up text field
            changeAlert.addTextField { (textField) in
                textField.text = ""
                textField.placeholder = "New album name"
            }
            
            //created a save action
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
                    print("Error saving changes to album name")
                }
                
                //Update Navigation Bar title too
                self.title = textField.text
            }))
            
            changeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Close alert")
          }))
            
            self.present(changeAlert, animated: true, completion: nil)
        })
        
        //Menu option action created for filtering the album for faces
        let facesAction = UIAction(title: "Find Faces", handler: { (action: UIAction)
            -> Void in
            
            self.filteredPhotosList = [] //empty the photo list
            //iterate over the photo list, find faces in each photo individually
            for photo in self.photosList {
                let faces = self.detectFace(photo: photo)
                
                if(faces){
                    self.filteredPhotosList.append(photo)
                }
            }
            //Reload the collection so it shows the filtered list
            self.galleryCollection.reloadData()
            
        })
        
        let menuItem = UIMenu(title: "", options: .displayInline, children: [addAction, nameAction, facesAction, settingsAction])
        
        //attach the menu item to the more button
        moreButton.menu = menuItem
    }
    
    //MARK: Face Detection
    
    ///Try to detect a face in an image and returns a boolean
    func detectFace(photo: UIImage) -> Bool {
        
        //Make Vision request for face detection
        let faceRequest = VNDetectFaceRectanglesRequest(completionHandler: faceDetected)
        let handler = VNImageRequestHandler(cgImage: photo.cgImage!, options: [:]) //take photo as cgImage
        
        do {
            try handler.perform([faceRequest]) //perform face request
        } catch {
            print(error)
        }
        
        //Checks for when no faces have been detected
        if (faceRequest.results!.count == 0){
            return false
        }
        //Checks for when a face has been detected
        else {
            return true
        }
    }
      
    ///Completion handler function for the face detection request
    func faceDetected(request: VNRequest, error: Error?){
        guard (request.results as? [VNFaceObservation]) != nil else {
              return
            }
    }

    //MARK: Core Data
    
    ///Function for updating what is being store persistentl in core data
    func updateCoreData(){
        
        //Convert from UIImage to Data
        let photosDataList = convertPhotosToData(photoList: photosList)
        
        //Accessing core data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        
        //Encode image data
        var photos: Data? //declare variable for use
        do {
            photos = try NSKeyedArchiver.archivedData(withRootObject: photosDataList, requiringSecureCoding: true)
        } catch {
            print("Error encoding image data")
        }
        selectedAlbum?.photoGallery = photos

        //save to core data
        do {
          try context.save()
        } catch {
           print("Error saving image data")
        }
        
    }
    
    ///Function checks if there are no photos and alters labels based on this
    func checkForPhotos(){ //rename to -> check for photos
        
        let photoCount = filteredPhotosList.count
       
        //Hide and show relevant labels
        if (filteredPhotosList.isEmpty) {
            label.isHidden = false
            buttonClicked.isEnabled = false //disable select button, when there are no images in the gallery
            photoCountLabel.isHidden = true
        }
        else {
            label.isHidden = true
            buttonClicked.isEnabled = true
            
            //Display photo count label
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
    
    ///Function prepare the info needed from this screen to the next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Checks which segue is about to be used
        if(segue.identifier == "toSettings"){
            let galleryDetail = segue.destination as? settingsViewController
            galleryDetail!.selectedAlbum = selectedAlbum //updates which album is selected
            
        }
    }
    
    

}
