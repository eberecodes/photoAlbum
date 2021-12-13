//
//  galleryVC.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 08/12/2021.
//

import UIKit
import CoreData

class galleryVC: UIViewController, UIImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {
    //changed the size of cell to custom - 120 x 120
    
   // var pickImage = UIImagePickerController()
    var photos = [UIImage]()
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath)
    
        
        if let imageView = imageCell.viewWithTag(1000) as? UIImageView {
               imageView.image = photos[indexPath.item]
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

            photos.insert(image, at: 0)
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
        
     
    }
    
    /*
save function
     
     @IBAction func save(_ sender: Any) {
        
     
     
     let appDelegate = UIApplication.shared.delegate as! AppDelegate
     let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
     let entity = NSEntityDescription.entity(forEntityName: "Album", in: context)
     let newAlbum = Album(entity: entity!, insertInto: context)
     newAlbum.id = albumList.count as NSNumber
     newAlbum.title = TitleTF.text
     
     do{
         try context.save()
         albumList.append(newAlbum)
         //navigationController?.popViewController(animated: true) I use an alert
     }
     catch{
         print("Error saving context")
     }
     }
  
    */

}
