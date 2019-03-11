//
//  RentalCell.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-19.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse
import DateTools

protocol RentalCellDelegate {
    func onLocationRentalOnMap(rental: Rental)
    func onBookingAppointment(rental: Rental)
}

class RentalCell: UITableViewCell {

    var delegate: RentalCellDelegate?
    
    @IBOutlet weak var pricePerMonthLabel: UILabel!
    @IBOutlet weak var floorAreaSizeLabel: UILabel!
    @IBOutlet weak var numerOfRoomsLabel: UILabel!
    @IBOutlet weak var bookingButton: UIButton!
    @IBOutlet weak var realtorLabel: UILabel!
    @IBOutlet weak var realtorAvatarImageView: PFImageView!
    @IBOutlet weak var frontImageView: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var featuresLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var availbleDateLabel: UILabel!
    
    
    var rental: Rental? {
        didSet {
            setRental(rental)
        }
        
        
    }
    
    func setRental(_ rental: Rental?) {
        
        self.frontImageView.image = UIImage(named: "logo")
        
        if let rental = rental {
            
            if let realtor = rental.realtor {
                setRealtor(realtor)
            }
            
            self.nameLabel.text = rental.name
            self.featuresLabel.text = rental.features
            self.addressLabel.text = rental.address
            self.numerOfRoomsLabel.text = "\(rental.numberOfRooms)"
            self.pricePerMonthLabel.text = "$\(rental.pricePerMonth)"
            self.floorAreaSizeLabel.text = "\(rental.floorSize)"
            self.availbleDateLabel.text = (rental.availbleDate as NSDate).timeAgoSinceNow()
            
            if let frontImage = rental.frontImage {
                self.frontImageView.file = frontImage
                self.frontImageView.loadInBackground()
            }
            
            
        }else{
            self.nameLabel.text = "..."
            self.featuresLabel.text = "..."
            self.numerOfRoomsLabel.text = "..."
            self.pricePerMonthLabel.text = "..."
            self.floorAreaSizeLabel.text = "..."
            self.addressLabel.text = "..."
            self.availbleDateLabel.text = "..."
            
            
            
        }
     
    }
    
    func setRealtor(_ user: PFUser?) {
        
        //            if user.objectId != oldValue.objectId  {
        if let user = user {
            self.realtorLabel.text = user.username
            if let file = user.avatar {
                
                self.realtorAvatarImageView.file = file
                self.realtorAvatarImageView.loadInBackground()
            }
            
        }else{
            self.realtorAvatarImageView.image = UIImage(named: "user")
            self.realtorLabel.text = ""
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

    @IBAction func onLocateRental(_ sender: Any) {
        guard (self.rental != nil) else {
            return
        }
        self.delegate?.onLocationRentalOnMap(rental: self.rental!)
    }
    
    @IBAction func onBookingAppointment(_ sender: Any) {
        guard (self.rental != nil) else {
            return
        }
        self.delegate?.onBookingAppointment(rental: self.rental!)
    }
}
