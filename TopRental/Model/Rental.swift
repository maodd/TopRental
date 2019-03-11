//
//  Rental.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-13.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

@objc enum RentalStatus: Int {
    case draft = 0
    case available
    case rented
}

public class Rental: PFObject, PFSubclassing {
    public static func parseClassName() -> String {
        return "Rental"
    }
    
    @NSManaged dynamic var realtor: PFUser?
    @NSManaged dynamic var location: PFGeoPoint
    @NSManaged dynamic var address: String
    @NSManaged dynamic var name: String
    @NSManaged dynamic var features: String
    @NSManaged dynamic var floorSize: Int
    @NSManaged dynamic var pricePerMonth: Int
    @NSManaged dynamic var numberOfRooms: Int
    @NSManaged dynamic var status: RentalStatus
    @NSManaged dynamic var geoLocation: PFGeoPoint
    @NSManaged dynamic var publishedAt: Date?
    @NSManaged dynamic var frontImage: PFFileObject?

    var availbleDate: Date {
        return self.publishedAt ?? self.updatedAt!
    }



}
