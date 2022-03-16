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

class albumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating{
    
    //Persistent storage
    let userDefaults = UserDefaults.standard
    
    private var saveAction: UIAlertAction!
    
    //Stores the currently selected index
    private var selectedIndex: IndexPath = []
    
    
    private var firstLoad = true //rename
    
    //test if I can make this private
    var authenticated = false
    
    private var filteredAlbums: [Album]!
    
    @IBAction func editButon(_ sender: UIBarButtonItem) {
        //Alternate between not editting and editing
        self.table.isEditing = !(self.table.isEditing)
        
        //Button title changes if in edit mode
        if (self.table.isEditing) {
            sender.title = "Done"
        }
        else {
            sender.title = "Edit"
        }
        
    }
    
    //MARK: Add album button
    @IBAction func addButton(_ sender: Any) {
        
        //Create the alert controller for new album creation
        let alert = UIAlertController(title: "New Album", message: "Enter album name", preferredStyle: .alert)

        alert.addTextField { (textField) in
            textField.placeholder = "Album name"
            textField.text = ""
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged) //monitor changes to text field
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
        //Disable save action whilst there is nothing entered
        saveAction.isEnabled = false
        alert.addAction(saveAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var table: UITableView!
    
    
    //MARK: Table view set up
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        selectedIndex = indexPath
        
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
                else {
                    passwordAlert?.message = "The password you entered was incorrect. Please try again..."
                    passwordAlert?.textFields![0].text = "" //clear the text field
                    self.present(passwordAlert!, animated: true, completion: nil)
                }
                
            }))
            
            //TODO: check if gesture authentication has been set up
            let gestureAction = UIAlertAction(title: "Use Gesture Authentication", style: .destructive, handler: { (action: UIAlertAction!) in
                
                //Only if gesture setup is complete - check userdefaults (otherwise disable)
                print("go to gesture authentication")
                self.performSegue(withIdentifier: "toGestureCheck", sender: nil)
                
            })
            passwordAlert.addAction(gestureAction)
            
            passwordAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("Close alert")
            }))
            
            if(userDefaults.bool(forKey: "gestureSetup")){
                gestureAction.isEnabled = true
            } else{
                gestureAction.isEnabled = false
            }
            
            self.present(passwordAlert, animated: true, completion: nil)
        }
        //Scenario 2: the album is unlocked
        else{
            performSegue(withIdentifier: "toGallery", sender: nil)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredAlbums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //UI - hiding the first separator line
        tableView.tableHeaderView = UIView()
        
        let albumCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let thisAlbum: Album!
        
        //thisAlbum = albumList[indexPath.row]
        thisAlbum = filteredAlbums[indexPath.row]
        
        //Customising the text in the cell
        albumCell.textLabel?.text = "   "+thisAlbum.title
        //albumCell.textLabel?.font = .systemFont(ofSize: 20)
        //albumCell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        //Helvetica is the other font i tried
        //albumCell.textLabel?.font = UIFont.init(name: "NotoSansOriya", size:23)
        albumCell.textLabel?.textColor = UIColor.darkGray
        //albumCell.textLabel?.font = UIFont.init(name: "Headline", size:20)

        
        //albumCell.textLabel.font=[UIFont fontWithName:@"Arial Rounded MT Bold" size:15.0];
        albumCell.backgroundColor = UIColor.clear
        albumCell.accessoryType = .disclosureIndicator
     
        
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
        
        
        //MARK: Displays album lock status
        if (thisAlbum.lockStatus == "Unlocked"){
            //albumCell.imagePreview.image = UIImage(named: "Unlock")
            albumCell.imagePreview.image = UIImage(systemName: "lock.open")
            albumCell.imagePreview.tintColor = .systemYellow
        }
        else{
            //albumCell.imagePreview.image = UIImage(named: "Lock")
            albumCell.imagePreview.image = UIImage(systemName: "lock")
            albumCell.imagePreview.tintColor = .systemYellow
        }
       
        
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
    
    //MARK: Prepare for segue to new screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //Checks which view controller it is being changed to
        if(segue.identifier == "toGallery"){
            
            let albumDetail = segue.destination as? galleryVC
            
            //Define type for selected album
            let selectedAlbum : Album!
            
            selectedAlbum = filteredAlbums[selectedIndex.row]
            albumDetail!.selectedAlbum = selectedAlbum
            
            table.deselectRow(at: selectedIndex, animated: true)
            
        }
    }
    
    //Will only save new album is a name is given
    @objc private func textFieldDidChange(_ field: UITextField) {
        if field.text != ""{
            saveAction.isEnabled = true
        }
    }
    
    //Programmatically create search controller
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Title of the navigation controller
        title = "Albums"
        
        table.delegate = self
        table.dataSource = self
  
        //Assign search controller in navigation item to the one I programmatically initialised
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        
        //Checks whether this the first time the view is being loaded
        if (firstLoad) {
            firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            //Make request for album
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Album")
            
            do {
                let results:NSArray = try context.fetch(request) as NSArray
                for r in results{
                    let album = r as! Album
                    
                    albumList.append(album)
                }
            }
            catch {
                print("Failed to fetch album from core data")
            }
        }
        //Copy the albums from album list to filteredAlbum to initialise it
        filteredAlbums = albumList
        self.table.keyboardDismissMode = .onDrag
    }
    
    
    //MARK: Search controller
    func updateSearchResults(for searchController: UISearchController) {
        //checks for text in serach bar
        guard let searchText = searchController.searchBar.text else{
            return
        }
        
        //empty the filtered albums array, in case empty search text
        filteredAlbums = []
        if (searchText == "") {
            filteredAlbums = albumList

        }
        
        else {
            //Loop through album array which contains the full list of albums
            for album in albumList{
                //Checks to see if any of the album title have ovverlapping contains text from the search
                if(album.title.uppercased().contains(searchText.uppercased())){
                    filteredAlbums.append(album)
                }
            }
        }
        
        //reload table data so its filtered
        self.table.reloadData()
    }
    
    ///The view is going to appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.table.reloadData()
        
        //Perform segue to gallery - authentication validated
        if (authenticated) {
            self.performSegue(withIdentifier: "toGallery", sender: nil)
            //reset value of authenticated
            authenticated = false
        }
        
    }
    
    @IBAction func unwindToFirstView( _ seg: UIStoryboardSegue) {
    }

    //MARK: Authentication confirmed
    @IBAction func unwindFromGestureAuthentication(_ sender: UIStoryboardSegue){
        if (sender.source is CameraViewController) {
            if let gestureVC = sender.source as? CameraViewController {
                authenticated = gestureVC.authenticated
   
            }
        }
    }

}



