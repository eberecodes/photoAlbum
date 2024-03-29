//
//  ViewController.swift
//  photoAlbum
//

import UIKit
import CoreData

var albumList = [Album]()

class AlbumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating{
    
    //Persistent storage
    let userDefaults = UserDefaults.standard
    
    private var saveAction: UIAlertAction!
    
    //Stores the currently selected index
    private var selectedIndex: IndexPath = []
    
    //Counts how many times the view has been loaded
    private var loadedCount = 0
    
    //UI
    private var noAlbumsLabel: UILabel!
    private var createButton: UIButton!
 
    
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
        
        //Text field allowing them to to enter the album name
        alert.addTextField { (textField) in
            textField.placeholder = "Album name"
            textField.text = ""
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged) //monitor changes to text field
        }
        
        //Close button action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            #if DEBUG
            print("Close alert")
            #endif
        }))
    
        //Save button action, so the album gets saved to Core Data
        saveAction = UIAlertAction(title: "Save", style: .default, handler: { [weak alert] (_) in
            
            //This text field should be the name of the album
            let textField = alert!.textFields![0]
            
            //Fetching
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            //Get a reference to it's persistent container
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            
            //Create an entity for Album
            let entity = NSEntityDescription.entity(forEntityName: "Album", in: context)
            
            //Set the values for the new album
            let newAlbum = Album(entity: entity!, insertInto: context)
            newAlbum.id = albumList.count as NSNumber
            newAlbum.title = textField.text
            newAlbum.lockStatus = "Unlocked"
                
            do {
                try context.save()
                albumList.append(newAlbum) //update album list
                self.filteredAlbums = albumList //update filtered list
                self.table.reloadData() //reload table so that new album appears
                self.checkForNoAlbums() //updates labels
            }
            catch{
                #if DEBUG
                print("Error saving new album")
                #endif
            }
            
        })
        //Disable save action whilst there is nothing entered
        saveAction.isEnabled = false
        alert.addAction(saveAction)
        
        //Present alert
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
        
        let albumCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! AlbumTableViewCell
        let thisAlbum: Album!
        
        thisAlbum = filteredAlbums[indexPath.row]
        
        
        //Customising the text in the cell
        albumCell.textLabel?.text = "   "+thisAlbum.title
        albumCell.textLabel?.textColor = UIColor.darkGray
        
        //UI
        albumCell.backgroundColor = UIColor.clear
        albumCell.accessoryType = .disclosureIndicator
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
                
        
        //MARK: Album lock status
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
                            
                            context.delete(album)
                            try context.save()
                            
                        }
                    }
                    
                    albumList.remove(at: indexPath.row)
                    self.filteredAlbums = albumList
                    self.table.deleteRows(at: [indexPath], with: .fade)
                    self.table.reloadData()
                    self.checkForNoAlbums()
                    
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
            
            let albumDetail = segue.destination as? GalleryViewController
            
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
        if (loadedCount == 0) {
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
                print("Failed to fetch albums from core data")
            }
        }
        loadedCount += 1
        
        //Copy the albums from album list to filteredAlbum to initialise it
       
        filteredAlbums = albumList
    
        self.table.keyboardDismissMode = .onDrag
        
        
        firstSetup()
        
        //checkForNoAlbums()
    }
    
    //Create UI features for when there are no albums
    func firstSetup(){
        
        //Label creation
        noAlbumsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        noAlbumsLabel.textAlignment = .center
        noAlbumsLabel.text = "No Albums"
        noAlbumsLabel.textColor = .systemGray
        noAlbumsLabel.font = UIFont.boldSystemFont(ofSize: 20)
        
        //Button creation
        createButton = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 60))
        createButton.setTitle("Add", for: .normal)
        createButton.setTitleColor(.systemYellow, for: .normal)
        createButton.backgroundColor = .clear
       // createButton.titleLabel?.textColor = .systemYellow
        createButton.addTarget(self, action: #selector(addButton(_:)), for: .touchUpInside)

        
        //Stack view creation
        let stackView = UIStackView(arrangedSubviews: [noAlbumsLabel, createButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false //use auto layout
        self.view.addSubview(stackView)
        //Add constraint
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        checkForNoAlbums()
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
        
        //Reload table data so its filtered
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
    
    ///Function checks if there are no albums and alters label based on this
    func checkForNoAlbums(){
        
       
        if filteredAlbums.isEmpty
        {
            print("empty")
            noAlbumsLabel.isHidden = false
            createButton.isHidden = false
        }
        else {
            print("not empty")
            noAlbumsLabel.isHidden = true
            createButton.isHidden = true
        }
        
        //Reload table data
        table.reloadData()
        
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



