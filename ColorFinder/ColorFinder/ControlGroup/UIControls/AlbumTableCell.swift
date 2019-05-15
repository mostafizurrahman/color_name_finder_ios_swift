//
//  AlbumTableCell.swift
//  TextOnPhoto
//
//  Created by Mostafizur Rahman on 26/2/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class AlbumTableCell: UITableViewCell {

    @IBOutlet weak var tableAlbumIcon: UIImageView!
    @IBOutlet weak var tableAlbumTitle: UILabel!
    @IBOutlet weak var tableImageCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
