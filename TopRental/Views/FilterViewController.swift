//
//  FilterViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-19.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit

class FilterSettings {
    static let floorSizeRanges = [(0,Int.max),(0,500),(500,1000),(1000,2000),(2000,Int.max)]
    static let pricePerMonthRanges = [(0,Int.max),(0,1000),(1000,2000),(2000,3000),(3000,Int.max)]
    
}

enum FilterSection : Int {
    case numberOfRooms
    case floorAreaSize
    case pricePerRange
    
}

protocol FilterViewControllerDelegate {
    func getCurrentFilter() -> (Int, Int, Int)
    
    func setCurrentFilter(_: (Int, Int, Int))
}

class FilterViewController: UITableViewController {

    var delegate: FilterViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.reloadData()
        
        let (numberOfRoomeIdx, floorSizeIdx, priceIdx) = delegate?.getCurrentFilter() ?? (0,0,0)
        
        tableView.selectRow(at: IndexPath(row: numberOfRoomeIdx, section: FilterSection.numberOfRooms.rawValue), animated: false, scrollPosition: .none)
        tableView.selectRow(at: IndexPath(row: floorSizeIdx, section: FilterSection.floorAreaSize.rawValue), animated: false, scrollPosition: .none)
        tableView.selectRow(at: IndexPath(row: priceIdx, section: FilterSection.pricePerRange.rawValue), animated: false, scrollPosition: .none)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let idx = tableView.indexPathsForSelectedRows?.first{$0.section == FilterSection.numberOfRooms.rawValue}
        var numberOfRooms = idx!.row
        if  numberOfRooms > 0 {
            let cell = tableView.cellForRow(at: idx!) as! NumberOfRoomsCell
            numberOfRooms = cell.numberOfRooms
        }
        
        let floorAreaFilterIdx = tableView.indexPathsForSelectedRows?.first{$0.section == FilterSection.floorAreaSize.rawValue}
        let pricePerMonthFilterIdx = tableView.indexPathsForSelectedRows?.first{$0.section == FilterSection.pricePerRange.rawValue}
        self.delegate?.setCurrentFilter((numberOfRooms, (floorAreaFilterIdx?.row)!, (pricePerMonthFilterIdx?.row)!))
    }
    // MARK: - Table view data source

    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case FilterSection.numberOfRooms.rawValue:
            return "Number of Rooms"
        case FilterSection.floorAreaSize.rawValue:
            return "Floor Area Size"
        case FilterSection.pricePerRange.rawValue:
            return "Price per Month"

        default:
            return nil
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case FilterSection.numberOfRooms.rawValue:
            return 2
        case FilterSection.floorAreaSize.rawValue:
            return FilterSettings.floorSizeRanges.count
        case FilterSection.pricePerRange.rawValue:
            return FilterSettings.pricePerMonthRanges.count

        default:
            return 0
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        // Configure the cell...
        switch indexPath.section {
        case FilterSection.numberOfRooms.rawValue:
            if indexPath.row > 0 {
                return tableView.dequeueReusableCell(withIdentifier: "numberOfRoomsCell", for: indexPath)
            }
            return tableView.dequeueReusableCell(withIdentifier: "allCell", for: indexPath)

        case FilterSection.floorAreaSize.rawValue:
            if indexPath.row > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "floorAreaSizeRangeCell", for: indexPath)
                let label = cell.viewWithTag(1) as! UILabel
                let range = FilterSettings.floorSizeRanges[indexPath.row]
                if range.1 == Int.max {
                    label.text = "greater than \(range.0)"
                }else{
                    label.text = "from \(range.0) to \(range.1)"
                }
                
                return cell
            }
            return tableView.dequeueReusableCell(withIdentifier: "allCell", for: indexPath)
        case FilterSection.pricePerRange.rawValue:
            if indexPath.row > 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "pricePerMonthRangeCell", for: indexPath)
                let label = cell.viewWithTag(1) as! UILabel
                let range = FilterSettings.pricePerMonthRanges[indexPath.row]
                if range.1 == Int.max {
                    label.text = "greater than $\(range.0)"
                }else{
                    label.text = "from $\(range.0) to $\(range.1)"
                }
                
                return cell
            }
           
            
            return tableView.dequeueReusableCell(withIdentifier: "allCell", for: indexPath)

        default:
            fatalError()
        }
        

        return UITableViewCell()
    }
    
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        tableView.deselectAllRowsInSection(indexPath.section)
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
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
