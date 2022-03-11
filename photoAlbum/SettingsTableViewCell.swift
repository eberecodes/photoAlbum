//
//  SettingsTableViewCell.swift
//  photoAlbum
//
//  Created by Ebere Anukem on 11/03/2022.
//

import UIKit


//was testung this out but I think there must be a simpler solution, using table view
class SettingsTableViewCell: UITableViewCell {

    //drag image in
    //drag lock switch in
    

    @IBOutlet weak var switchLock: UISwitch!
    
    @IBOutlet weak var settingImageView: UIImageView!
    
    /*private let iconImage:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let settingsLabel: UILabel = {
        let settingsLabel = UILabel()
        settingsLabel.numberOfLines = 1
        return settingsLabel
    }()
    
    //constructor method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: "SettingsTableViewCell")
        contentView.addSubview(iconImage)
        contentView.addSubview(settingsLabel)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder){
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //reset everything
        iconImage.image = nil
        settingsLabel.text = nil
    }*/
}
