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
    
    @IBOutlet weak var requirementsTextView: UITextView!
    
    @IBAction func doneButton(_ sender: Any) {
        if (passwordField.text == confirmField.text) && requirementsCheck() {
            
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
            print("Password doesn't meet requirements")
            
            let requirementsAlert = UIAlertController(title: "Weak Password", message: "The password you entered doesn't meet requirements, try again...", preferredStyle: .alert)
            
            requirementsAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                print("OK")
            }))
            
            present(requirementsAlert, animated: true, completion: nil)
            
            //Reset textfields
            passwordField.text = ""
            confirmField.text = ""
        }
    }
    
    //Function to check if strong password requirements have been met.
    func requirementsCheck() -> Bool {
        
        //Using Regex to check it contains numbers, lower case, upper case, special characters and at least 8 chars
        let strongPassword = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[$@$#!%*?&]).{8,}$")
        
        //returns a bool
        let strong = strongPassword.evaluate(with: passwordField.text)
        
    
        
        return strong
    }
    
    @IBOutlet weak var passwordLabel: UILabel!
    
    @IBOutlet weak var confirmLabel: UILabel!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmField: UITextField!
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Create Password"
        
    }
    

   

}
