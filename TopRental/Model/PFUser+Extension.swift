//
//  PFUser+Extension.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-13.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

enum Role : Int {
    case client = 0
    case realtor
    case admin
}



extension PFUser {
    
    static let AdminRoleObjectId = "dZ9GEhJTSS"
    static let RealtorRoleObjectId = "pqF1FCQ5HD"
    
    var avatar : PFFileObject? {
        get { return self["avatar"] as? PFFileObject }
        set(file) {
            self["avatar"] = file
        }
    }
    
    var role : Role {
        
        if let roleObjectPointer = self["role"] as? PFObject {
            
            if  roleObjectPointer.objectId == PFUser.AdminRoleObjectId {
                return .admin
            }
            if  roleObjectPointer.objectId == PFUser.RealtorRoleObjectId {
                return .realtor
            }
            
            return .client
        }
        
        return .client
        
       
    }
    
    var isAdmin : Bool {
        return self.role == .admin
    }
    
    var isRealtor : Bool {
        return self.role == .realtor
    }
}
