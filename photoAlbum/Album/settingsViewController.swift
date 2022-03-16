//
//  settingsViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 10/12/2021.
//

import UIKit
import CoreData

//TODO: Help page
//TODO: Feedback page

class settingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    let userDefaults = UserDefaults.standard
    
    var selectedAlbum: Album? = nil
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    ///User has clicked the lock switch, update core data accoridingly
    @IBAction func switchChanged(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        
        //Accessing through unique ID
        let albumID = selectedAlbum?.id

        //Going from unlocked to locked
        if(selectedAlbum?.lockStatus == "Unlocked"){
            
            //Check if a password has been set up from user defaults
            if(userDefaults.bool(forKey: "PasswordSetup")){
                
                //Update coreData
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
                self.navigationController?.popToRootViewController(animated: true)
            }
            else{
                //Set up password
                self.performSegue(withIdentifier: "toPassword", sender: nil)
            }
            
        }
        
        //Locked to unlocked
        else{
            //Update coredata
            request.predicate = NSPredicate(format: "%@ IN id", albumID!)
            
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
            
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Album Settings"
        
        //debugging
        print(selectedAlbum?.lockStatus ?? "issue")
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        //Table view content
        settingDetails = [("", [" Lock Album"], ["lock"]), ("General", [" Change Password", " Submit Feedback", " Help"], ["hand.raised", "message", "questionmark.circle"])]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //Check which view controller it will change to
        if(segue.identifier == "toPassword"){
            let settingsDetail = segue.destination as? PasswordViewController
            settingsDetail!.selectedAlbum = selectedAlbum
            
        }
    }
    

    var settingDetails = [(String , [String], [String])]()

    //MARK: Table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingDetails.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingDetails[section].0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingDetails[section].1.count
    }
    
    ///Perform action depending on which row was clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section > 0){
            //Change password
            if (indexPath.row == 0){
                //Create alert confirming their original password
                let passwordChangeAlert = UIAlertController(title: "Confirm Password", message: "Enter your original password", preferredStyle: .alert)
                
                //text field - for password entry
                passwordChangeAlert.addTextField { (textField) in
                    textField.text = ""
                    textField.isSecureTextEntry = true
                }
                
                passwordChangeAlert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak passwordChangeAlert] (_) in
                    let textField = passwordChangeAlert!.textFields![0]
                    
                    let retrievedPass: String? = KeychainWrapper.standard.string(forKey: "albumPassword")
                    if(textField.text == retrievedPass){
                        self.performSegue(withIdentifier: "toPassword", sender: nil)
                    }
                    else {
                        passwordChangeAlert?.message = "The password you entered was incorrect. Please try again..."
                        passwordChangeAlert?.textFields![0].text = "" //clear the text field
                        self.present(passwordChangeAlert!, animated: true, completion: nil)
                    }
                    
                }))
                
                passwordChangeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                    print("Close alert")
                }))
                
                self.present(passwordChangeAlert, animated: true, completion: nil)
            }
            
            //Feedback page
            else if (indexPath.row == 1){
                performSegue(withIdentifier: "toFeedback", sender: nil)
            }
            
            //Help page
            else {
                performSegue(withIdentifier: "toHelp", sender: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
       
        settingsCell.textLabel?.text = settingDetails[indexPath.section].1[indexPath.row]

        //UI changes
        settingsCell.backgroundColor = UIColor.clear
        //settingsCell.layer.cornerRadius = 7
        
        //tableView.layer.cornerRadius = 7
        tableView.backgroundColor = UIColor.clear
        //tableView.layer.masksToBounds = true
        
        //Stops table view from moving around
        tableView.isScrollEnabled = false
        
        //These changes do get made to the colum for locking album
        if(indexPath.section > 0){
            //Added a disclosure indicator, to signify more detail to be found once clicked
            settingsCell.accessoryType = .disclosureIndicator
            settingsCell.switchLock.isHidden = true
        }
        else{
            //Determines switch status, from core data lock status value
            if(selectedAlbum?.lockStatus == "Unlocked"){
                settingsCell.switchLock.setOn(false, animated: true)
            }
            else{
                settingsCell.switchLock.setOn(true, animated: true)
            }
        }
        
        //Adde image to side of row
        settingsCell.settingImageView.image = UIImage(systemName: settingDetails[indexPath.section].2[indexPath.row])
        settingsCell.settingImageView.tintColor = .systemYellow
        settingsCell.separatorInset = .zero
        
        return settingsCell
    }
  
}
