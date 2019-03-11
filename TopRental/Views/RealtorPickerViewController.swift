//
//  RealtorPickerViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-17.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

protocol RealtorPickerViewControllerDelegate {
    func onRealorSelected(realtor: PFUser)
}

class RealtorPickerViewController: PFQueryTableViewController {
    
    var delegate: RealtorPickerViewControllerDelegate?
    
    var realtorSelected: PFUser?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 40
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView(frame: .zero)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = super.queryForTable()
//        query.whereKey("role", equalTo: PFUser.RealtorRoleObjectId)
        return query
    }

    override func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)
        
        
        if let realtorSelected = self.realtorSelected ,
            let idx = self.objects?.map({ (obj) -> String in
                obj.objectId!
            }).firstIndex(of: realtorSelected.objectId) {
                self.tableView.selectRow(at: IndexPath(row: idx, section: 0), animated: false, scrollPosition: .none)
        }
       
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RealtorCell", for: indexPath) as? UserCell
        
        // Configure the cell...
        cell?.user = self.objects?[indexPath.row] as? PFUser
        
        
        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realtor = self.objects?[indexPath.row]
        
        delegate?.onRealorSelected(realtor: realtor as! PFUser)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
