//
//  ViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 07/12/2021.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    var albumNames = [""]
    
    @IBOutlet var table: UITableView!
    
    @IBAction func add(_ sender: Any) {
        albumNames.insert("New", at: 0)
        //albumNames.append("New")
        
        table.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("tapped")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return albumNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = albumNames[indexPath.row]
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

