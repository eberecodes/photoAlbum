//
//  ViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 07/12/2021.
//
//TODO: work on 'Example' album and use that to build out album (database design will need to be considered) - peristent storage
//TODO: Add image view to the side of table view (for locked albums make it an image of a lock) otherwise use previw from their album
//TODO: add delete, edit and modify functionality -> perhaps hide functionality too

import UIKit

class albumViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    var albumNames = ["Example"] //can call this example or sample maybe
    
    
    @IBAction func addButton(_ sender: Any) {
        //albumNames.insert("New", at: 0)
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
            print("Text field: \(textField.text ?? "new")")
            self.albumNames.append(textField.text ?? "new")
            self.table.reloadData()
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var table: UITableView!
    
    

    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
        performSegue(withIdentifier: "toGallery", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return albumNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = albumNames[indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Albums"
        // Do any additional setup after loading the view.
    }


}



