//
//  galleryVC.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 08/12/2021.
//

import UIKit
import CoreData

class galleryVC: UIViewController {
    
    var selectedAlbum: Album? = nil
    
    
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
