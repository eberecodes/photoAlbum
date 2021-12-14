//
//  ViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 07/12/2021.
//
//TODO: work on 'Example' album and use that to build out album (database design will need to be considered) - persistent storage
//TODO: persistent storage of images in album*.
//TODO: delete functionality for images in album
//TODO: Add image view to the side of table view (for locked albums make it an image of a lock) otherwise use preview from their album
//TODO: add edit functionality -> perhaps hide functionality too

import UIKit

import CoreData

var albumList = [Album]()

class albumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    var firstLoad = true //rename
    
    var albumNames = ["Example"] //can call this example or sample maybe
    
    
    
    @IBAction func addButton(_ sender: Any) {
        //albumNames.append("New")
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "New Album", message: "Enter album name", preferredStyle: .alert)

        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = ""
            //potentially restrict so no empty field can be entered
        }
        
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Album", in: context)
            let newAlbum = Album(entity: entity!, insertInto: context)
            newAlbum.id = albumList.count as NSNumber
            newAlbum.title = textField.text
            
            do{
                try context.save()
                albumList.append(newAlbum)
                self.table.reloadData()
                //navigationController?.popViewController(animated: true) I use an alert
            }
            catch{
                print("Error saving context")
            }
            
            
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var table: UITableView!
    
    

    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        performSegue(withIdentifier: "toGallery", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return albumNames.count
        return albumList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let albumCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let thisAlbum: Album!
        
        thisAlbum = albumList[indexPath.row]
        
        albumCell.textLabel?.text = thisAlbum.title
        
        albumCell.accessoryType = .disclosureIndicator
        
        return albumCell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deleteConfirmation = UIAlertController(title: "Remove Album", message: "Are you sure you want to delete the album \"\(albumList[indexPath.row].title!)\"?", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction) -> Void in
                
            
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
                
                do{
                    let results:NSArray = try context.fetch(request) as NSArray
                    for r in results{
                        let album = r as! Album
                        
                        if (album == albumList[indexPath.row]){
                            
                            album.deletedDate = Date() //don't actually need deleted date
                            context.delete(album)
                            try context.save()
                            
                            
                        }
                    }
                    
                    albumList.remove(at: indexPath.row)
                    self.table.deleteRows(at: [indexPath], with: .fade)
                    self.table.reloadData()
                    
                }
                catch{
                    print("failed to fetch")
                }
                
                
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {  (action: UIAlertAction) -> Void in
                print("Cancel album deletion")
            }

            deleteConfirmation.addAction(deleteAction)
            deleteConfirmation.addAction(cancelAction)

            present(deleteConfirmation, animated: true, completion: nil)
            
            
            
        }
        
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toGallery"){
            let indexPath = table.indexPathForSelectedRow!
            
            let albumDetail = segue.destination as? galleryVC
            
            let selectedAlbum : Album!
            selectedAlbum = albumList[indexPath.row]
            albumDetail!.selectedAlbum = selectedAlbum
            
            
            table.deselectRow(at: indexPath, animated: true)
            
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Albums"
        // Do any additional setup after loading the view.
        
        if (firstLoad){
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
            
            do{
                let results:NSArray = try context.fetch(request) as NSArray
                for r in results{
                    let album = r as! Album
                    
                    albumList.append(album)
                }
            }
            catch{
                print("failed to fetch")
            }
        }
        
    }


}



