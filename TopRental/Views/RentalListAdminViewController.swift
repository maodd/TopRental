//
//  RentalListAdminViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-13.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

class RentalListAdminViewController: PFQueryTableViewController {

    @IBOutlet weak var statusSwitcher: UISegmentedControl!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        self.parseClassName = "Rental"
        self.textKey = "name"
        self.pullToRefreshEnabled = true
        self.objectsPerPage = 40
        
    }
    
    override func queryForTable() -> PFQuery<PFObject> {
        let query = super.queryForTable()
        
        query.whereKey("status", equalTo: self.statusSwitcher.selectedSegmentIndex)
        
        return query
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.titleView = self.statusSwitcher
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action:#selector(RentalListAdminViewController.addRental) )
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(AppNotification.RentalInfoChanged.rawValue), object: nil, queue: nil) { (notif) in
            
            self.loadObjects()
        }
    }
    
    @IBAction func onStatusSwitched(_ sender: Any) {
        
        self.loadObjects()
    }
    
    @objc func addRental() {
        self.performSegue(withIdentifier: "newRental", sender: nil)
    }

    func saveNewRental() {
        
        let rental = Rental()
        rental.address = "addr"
        rental.name = "rental"
        rental.features = "features"
        rental.floorSize = Int.random(in: 1000 ..< 2500)
        rental.numberOfRooms = Int.random(in: 1 ..< 5)
        rental.pricePerMonth = Int.random(in: 500 ..< 2500)
        rental.status = RentalStatus.draft
        rental.realtor = PFUser.current()!
        
        rental.saveInBackground { (success, error) in
            if success {
                NotificationCenter.default.post(name: NSNotification.Name(AppNotification.RentalInfoChanged.rawValue), object: nil)
            }
        }
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.objects?.count)!
    }
 

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RentalAdminCell", for: indexPath) as? RentalAdminCell
        
        // Configure the cell...
        
        cell?.rental = self.objects?[indexPath.row] as! Rental
        
        
        
        
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
        if let vc = segue.destination as? RentalDetailsAdminViewController {
            if let sender = sender as? RentalAdminCell {
                vc.rental = sender.rental
            }else{
                vc.rental = Rental()
            }
        }
    }
 

}
