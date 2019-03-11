//
//  NumberOfRoomsCell.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-19.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit

class NumberOfRoomsCell: UITableViewCell {

    @IBOutlet weak var numberOfRoomsLabel: UILabel!
    @IBOutlet weak var numberOfRoomsStepper: UIStepper!
    
    
    var numberOfRooms:Int {
        get{ return Int(numberOfRoomsStepper.value) }
        set{
            numberOfRoomsStepper.value = Double(numberOfRooms)
            numberOfRoomsLabel.text = "\(numberOfRooms)"
        }}
    
    @IBAction func onNumberOfRoomsChanged(_ sender: UIStepper) {
        
        self.numberOfRooms = Int(sender.value)
        
        
        
        let idx = self.tableView?.indexPath(for: self)
        self.tableView?.deselectAllRowsInSection((idx?.section)!)
        
        
        self.tableView?.selectRow(at: idx, animated: false, scrollPosition: .none)
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

extension UITableView {
    func deselectAllRowsInSection(_ section: Int) {
        for idx in self.indexPathsForSelectedRows ?? [] {
            if idx.section == section {
                self.deselectRow(at: idx, animated: true)
            }
        }
    }
}

extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = self.superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
}

extension UITableViewCell {
    var tableView: UITableView? {
        return self.parentView(of: UITableView.self)
    }
}
