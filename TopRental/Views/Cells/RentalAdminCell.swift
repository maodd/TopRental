//
//  RentalAdminCell.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-13.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

class RentalAdminCell: UITableViewCell {

    var rental: Rental = Rental() {
        didSet{
            self.textLabel?.text = rental.name
            self.detailTextLabel?.text = rental.address
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
