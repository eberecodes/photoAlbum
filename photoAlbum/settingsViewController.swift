//
//  settingsViewController.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 10/12/2021.
//

import UIKit

class settingsViewController: UIViewController {

    //consider if I need to change switch settings
    @IBOutlet weak var lockSwitch: UISwitch!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Album Settings"
        // Do any additional setup after loading the view.
    }
    


}
