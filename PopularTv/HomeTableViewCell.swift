//
//  HomeTableViewCell.swift
//  PopularTv
//
//  Created by Ter, Paul D on 5/6/19.
//  Copyright © 2019 Ter, Paul D. All rights reserved.
//

import UIKit

class HomeTableViewCell: UITableViewCell {


 
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var movieImage: UIImageView!
     @IBOutlet weak var caption: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
