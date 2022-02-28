//
//  ViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 07/12/2021.
//
//TODO: Delete functionality for images in album
//TODO: Album settings page, including editing name
//TODO: slight issue with search bar, you can't delete an album when in search mode
//TODO: Implement change password functionality

import UIKit

import CoreData

var albumList = [Album]()

class albumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate{
    
    private var saveAction: UIAlertAction!
    
    @IBOutlet weak var searchBar: UISearchBar!
    var firstLoad = true //rename
    
    
    var filteredAlbums: [Album]!
    
    
    @IBAction func addButton(_ sender: Any) {
        
        //Create the alert controller for new album creation
        let alert = UIAlertController(title: "New Album", message: "Enter album name", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Album name"
            textField.text = ""
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged) //motnior changes to text field
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Close alert")
        }))
    
        
        saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Album", in: context)
            let newAlbum = Album(entity: entity!, insertInto: context)
            newAlbum.id = albumList.count as NSNumber
            newAlbum.title = textField.text
            newAlbum.lockStatus = "Unlocked"
                
            do{
                try context.save()
                albumList.append(newAlbum)
                self.filteredAlbums = albumList
                self.table.reloadData()
                   
            }
            catch{
                print("Error saving context")
            }
            
        })
        saveAction.isEnabled = false
        alert.addAction(saveAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var table: UITableView!
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        let currAlbum = filteredAlbums[indexPath.row]
        
        //Scenario 1: The album is locked
        if(currAlbum.lockStatus=="Locked"){
            let passwordAlert = UIAlertController(title: "View '\(currAlbum.title!)' Album", message: "To view locked albums enter your password", preferredStyle: .alert)
            
            //text field - for password entry
            passwordAlert.addTextField { (textField) in
                textField.text = ""
                textField.isSecureTextEntry = true
            }
            
            passwordAlert.addAction(UIAlertAction(title: "Enter", style: .default, handler: { [weak passwordAlert] (_) in
                let textField = passwordAlert!.textFields![0]
                
                let retrievedPass: String? = KeychainWrapper.standard.string(forKey: "albumPassword")
                if(textField.text == retrievedPass){
                    self.performSegue(withIdentifier: "toGallery", sender: nil)
                }
                else{
                    passwordAlert?.message = "The password you entered was incorrect. Please try again..."
                    passwordAlert?.textFields![0].text = "" //clear the text field
                    self.present(passwordAlert!, animated: true, completion: nil)
                }
                
            }))
            
            passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Close alert")
          }))
            
            self.present(passwordAlert, animated: true, completion: nil)
        }
        //Scenario 2: the album is unlocked
        else{
            performSegue(withIdentifier: "toGallery", sender: nil)
        }
        
        //performSegue(withIdentifier: "toGallery", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let albumCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let thisAlbum: Album!
        
        //thisAlbum = albumList[indexPath.row]
        thisAlbum = filteredAlbums[indexPath.row]
        
        albumCell.textLabel?.text = "    "+thisAlbum.title
        
        //albumCell.layer.masksToBounds = true
        albumCell.backgroundColor = UIColor.systemGray4
        albumCell.accessoryType = .disclosureIndicator
        //albumCell.layer.cornerRadius = 9
        if indexPath.row == 0{
            albumCell.layer.cornerRadius = 9
            albumCell.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        if indexPath.row == ((filteredAlbums.count)-1){
            albumCell.layer.cornerRadius = 9
            albumCell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        //tableView.layer.cornerRadius = 7
        //tableView.layer.masksToBounds = true
        
        
        //MARK: Displays album lock status
        if (thisAlbum.lockStatus == "Unlocked"){
            albumCell.imagePreview.image = UIImage(named: "Unlock")
        }
        else{
            albumCell.imagePreview.image = UIImage(named: "Lock")
        }
       
        
        return albumCell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let deleteConfirmation = UIAlertController(title: "Remove Album", message: "Are you sure you want to delete the album \"\(albumList[indexPath.row].title!)\"?", preferredStyle: .actionSheet)
            /*let deleteConfirmation = UIAlertController(title: "Remove Album", message: "Are you sure you want to delete the album \"\(filteredAlbums[indexPath.row].title!)\"?", preferredStyle: .actionSheet)*/
            
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
                    self.filteredAlbums = albumList
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
            //selectedAlbum = albumList[indexPath.row]
            selectedAlbum = filteredAlbums[indexPath.row]
            albumDetail!.selectedAlbum = selectedAlbum
            
            
            table.deselectRow(at: indexPath, animated: true)
            
        }
    }
    
    @objc private func textFieldDidChange(_ field: UITextField) {
        if field.text != ""{
            saveAction.isEnabled = true
        }
    }
    
    //MARK: Search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredAlbums = []
        if(searchText == ""){
            filteredAlbums = albumList
            searchBar.resignFirstResponder()
        }
        else{
            for album in albumList{
                if(album.title.uppercased().contains(searchText.uppercased())){
                    filteredAlbums.append(album)
                }
            }
        }
        
        self.table.reloadData()
    }
    /*func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // hides the keyboard.
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        searchBar.delegate = self
        title = "Albums"
      
        
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
        filteredAlbums = albumList
        self.table.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.table.reloadData()
    }
    
    @IBAction func unwindToFirstView( _ seg: UIStoryboardSegue) {
    }


}



