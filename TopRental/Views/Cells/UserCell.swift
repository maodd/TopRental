//
//  UserCell.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-12.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

class UserCell: PFTableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatorImageView: PFImageView!
    
    private var _user: PFUser?
    var user: PFUser? {
        get {return _user}
        set(newValue) {

            setUser(newValue)
        }
        
    }
    
    func setUser(_ user: PFUser?) {
        _user = user
        //            if user.objectId != oldValue.objectId  {
        if let user = user {
            self.userNameLabel.text = user.username
            if let file = user.avatar {
                
                self.avatorImageView.file = file
                self.avatorImageView.loadInBackground()
            }
            
        }else{
            self.avatorImageView.image = UIImage(named: "user")
            self.userNameLabel.text = ""
        }
        //            }
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
