//
//  PasswordViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 24/01/2022.
//

import UIKit
import CoreData

//TODO: will need to ensure something is always put into password fields
//TODO: Create general requirements for password
class PasswordViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    var selectedAlbum: Album? = nil
    
    @IBAction func doneButton(_ sender: Any) {
        if passwordField.text == confirmField.text{
            //MARK: Saving lockStatus to CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
            
            /*let albumName = selectedAlbum?.title
            request.predicate = NSPredicate(format: "title == %@", NSString.init(string: albumName!))*/
            
            //accessing through unique ID
            let albumID = selectedAlbum?.id
            request.predicate = NSPredicate(format: "%@ IN id", albumID!)
            
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
            
            //MARK: Save password to keychain
            let saved:Bool = KeychainWrapper.standard.set(passwordField.text!, forKey: "albumPassword")
            
            if(saved){
                print("Password has been succesfully saved")
            }
            else{
                print("Issue saving password")
            }
            
            userDefaults.set(true, forKey: "PasswordSetup")
            
            //segue back to albums 
            performSegue(withIdentifier: "toAlbums", sender: nil)
            print("password created")
        }
        else{
            //TODO: an alert - prompting then to re-enter
            print("password don't match")
        }
    }
    
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var confirmLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmField: UITextField!
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Password"
        // Do any additional setup after loading the view.
    }
    

   

}
