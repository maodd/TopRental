//
//  UsersViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-12.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

class UsersViewController: PFQueryTableViewController {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 40
        
    }
    
 
    
    
    var clients : [PFUser] {
        return self.filterUsersByRole(role: .client)
    }
    
    var realtors : [PFUser] {
        return self.filterUsersByRole(role: .realtor)
    }
    
    var admins : [PFUser] {
        return self.filterUsersByRole(role: .admin)
    }
    
    func filterUsersByRole(role: Role) -> [PFUser] {
        return self.objects!.filter({ (user ) -> Bool in
            (user as! PFUser).role == role
        }) as! [PFUser]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(UsersViewController.addUser) )
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(AppNotification.UserInfoChanged.rawValue), object: nil, queue: nil) { (notif) in
            
            self.loadObjects()
        }
        
    }
    
    @objc func addUser() {
        self.performSegue(withIdentifier: "newUser", sender: nil)
    }

    override func objectsDidLoad(_ error: Error?) {
        super.objectsDidLoad(error)

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [self.clients.count, self.realtors.count, self.admins.count][section]
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["Clients", "Realtors", "Admins"][section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell

        // Configure the cell...
        switch indexPath.section {
        case 0:
            cell?.user = self.clients[indexPath.row]
        case 1:
            cell?.user = self.realtors[indexPath.row]
        case 2:
            cell?.user = self.admins[indexPath.row]
            
        default:
            fatalError()
        }
        
        

        return cell ?? UITableViewCell()
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let vc = segue.destination as? UserDetailsViewController {
            if let sender = sender as? UserCell {
                vc.user = sender.user
            }else{
                vc.user = PFUser()
            }
        }
        
    }
 

}
