//
//  settingsViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 10/12/2021.
//

import UIKit
import CoreData

class settingsViewController: UIViewController {
    let userDefaults = UserDefaults.standard
    
    //consider if I need to change switch settings
    @IBOutlet weak var lockSwitch: UISwitch!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var selectedAlbum: Album? = nil
    
    @IBAction func switchOn(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        let albumName = selectedAlbum?.title
        
        //going from unlocked to locked
        //check if a password has been set up from user defaults
        if(selectedAlbum?.lockStatus == "Unlocked"){
            //simply update coreData
            if(userDefaults.bool(forKey: "PasswordSetup")){
                request.predicate = NSPredicate(format: "title == %@", NSString.init(string: albumName!))
                
                do {
                    let result:[NSManagedObject] = try context.fetch(request) as! [NSManagedObject]
                    if result.count != 0 { // Atleast one was returned
                        result[0].setValue("Locked", forKey: "lockStatus")
                    }
                  }
                catch{
                    print("Failed to fetch: \(error)")
                }
                
                do {
                    try context.save()
                   }
                catch {
                    print("Failed to save: \(error)")
                }
            }
            else{
                self.performSegue(withIdentifier: "toPassword", sender: nil)
            }
            
        }
        
        //locked to unlocked
        //update coredata
        else{
            /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
            let albumName = selectedAlbum?.title*/
            request.predicate = NSPredicate(format: "title == %@", NSString.init(string: albumName!))
            
            do {
                let result:[NSManagedObject] = try context.fetch(request) as! [NSManagedObject]
                if result.count != 0 { // Atleast one was returned
                    result[0].setValue("Unlocked", forKey: "lockStatus")
                }
              }
            catch{
                print("Failed to fetch: \(error)")
            }
            
            do {
                try context.save()
               }
            catch {
                print("Failed to save: \(error)")
            }
        }
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Album Settings"
        
        //debugging
        print(selectedAlbum?.lockStatus ?? "issue")
        
        //set the switch based on lock status
        if(selectedAlbum?.lockStatus == "Unlocked"){
            lockSwitch.setOn(false, animated: true)
        }
        else{
            lockSwitch.setOn(true, animated: true)
        }
        
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toPassword"){
            let settingsDetail = segue.destination as? PasswordViewController
            settingsDetail!.selectedAlbum = selectedAlbum
            
        }
    }

}
