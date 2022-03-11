//
//  settingsViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 10/12/2021.
//

import UIKit
import CoreData


class settingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let userDefaults = UserDefaults.standard
    
    //consider if I need to change switch settings
    @IBOutlet weak var lockSwitch: UISwitch!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var selectedAlbum: Album? = nil
    
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    @IBAction func switchOn(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
        //let albumName = selectedAlbum?.title
        
        //accessing through unique ID
        let albumID = selectedAlbum?.id

        
        //going from unlocked to locked
        //check if a password has been set up from user defaults
        if(selectedAlbum?.lockStatus == "Unlocked"){
            //simply update coreData
            if(userDefaults.bool(forKey: "PasswordSetup")){
                /*request.predicate = NSPredicate(format: "title == %@", NSString.init(string: albumName!))*/
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
                self.performSegue(withIdentifier: "toPassword", sender: nil)
            }
            
        }
        
        //Locked to unlocked
        //update coredata
        else{
            /*let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
            let albumName = selectedAlbum?.title*/
            /*request.predicate = NSPredicate(format: "title == %@", NSString.init(string: albumName!))*/
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
        
        
        
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        
        
        settingDetails = [("", [" Lock Album"], ["lock"]), ("General", [" Change Password", " Submit Feedback", " Help"], ["hand.raised", "message", "questionmark.circle"])]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toPassword"){
            let settingsDetail = segue.destination as? PasswordViewController
            settingsDetail!.selectedAlbum = selectedAlbum
            
        }
    }
    

    var settingDetails = [(String , [String], [String])]()

 
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingDetails.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingDetails[section].0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingDetails[section].1.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //perform action dependin on which row was clicked
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) as! SettingsTableViewCell
       
        //settingsCell.textLabel?.text = rowTitles[indexPath.row]
        settingsCell.textLabel?.text = settingDetails[indexPath.section].1[indexPath.row]
        //cell.textLabel?.text = aWorks[indexPath.section].1[indexPath.row].title
        settingsCell.backgroundColor = UIColor.systemGray4
        //settingsCell.detailTextLabel?.text =
        
        tableView.layer.cornerRadius = 7
        tableView.layer.masksToBounds = true
        
        if(indexPath.section > 0){ //doesn't get added to lock
            //Added a disclosure indicator, to signify more detail to be found once clicked
            settingsCell.accessoryType = .disclosureIndicator
            settingsCell.switchLock.isHidden = true
        }
        settingsCell.settingImageView.image = UIImage(systemName: settingDetails[indexPath.section].2[indexPath.row])
        
        return settingsCell
    }
  
}
