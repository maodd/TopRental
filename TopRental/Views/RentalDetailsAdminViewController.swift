//
//  RentalDetailsAdminViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-13.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import MapKit
import Parse
import JVFloatLabeledTextField
import YPImagePicker
import SVProgressHUD
import LocationPickerViewController

class RentalDetailsAdminViewController: UITableViewController {

    
    var rental : Rental = Rental()
    
    @IBOutlet weak var frontImageView: PFImageView!
    
    @IBOutlet weak var nameLabel: JVFloatLabeledTextField!
    @IBOutlet weak var featuresLabel: JVFloatLabeledTextField!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var floorAreaSizeField: UITextField!
    @IBOutlet weak var numberOfRoomsField: UITextField!
    @IBOutlet weak var numberOfRoomsStepper: UIStepper!
    @IBOutlet weak var pricePerMonthField: UITextField!
  
    @IBOutlet weak var realtorAvatarImageView: PFImageView!
    @IBOutlet weak var realtorNameLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var realtorCell: UserCell!
    
    
//    @IBOutlet weak var errorMessageLabel: UILabel!
    
    
    @IBOutlet weak var statusSwitcher: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        setDefaultsIfNeeded()
        
        refreshUI()
    }
    
    func setDefaultsIfNeeded() {
        if (self.rental.objectId == nil) {
            self.rental.numberOfRooms = 1
            self.rental.floorSize = 1000
            self.rental.pricePerMonth = 1000
            self.rental.status = .draft
            
            self.rental.realtor = PFUser.current()
            
            
        }else{
            
        }
    }
    func refreshUI()  {
        
        if (self.rental.objectId == nil) {
            self.deleteButton.isHidden = true
            self.title = "New Rental"
        }else{
            self.deleteButton.isHidden = false
            self.title = "Edit Rental"
        }
 
        self.nameLabel.text = rental.name
        self.addressLabel.text = rental.address
        
        self.statusSwitcher.selectedSegmentIndex = rental.status.rawValue
        
        self.featuresLabel.text = rental.features
        self.floorAreaSizeField.text = "\(rental.floorSize )"
        self.numberOfRoomsField.text = "\(rental.numberOfRooms )"
        self.numberOfRoomsStepper.value = Double(rental.numberOfRooms )
        self.pricePerMonthField.text = "\(rental.pricePerMonth )"
        
        if self.rental.frontImage != nil {
            self.frontImageView.file = self.rental.frontImage!
            self.frontImageView.loadInBackground()
        }else{
            self.frontImageView.image = UIImage(named: "logo")
        }
        
        if let realtor = rental.realtor {
            realtor.fetchIfNeededInBackground { (user:PFObject?, error:Error?) in
                //
                self.realtorCell.setUser( user as? PFUser )
            }
            
        }
        
        
        addPinOnMapView()
        
    }
    
    func addPinOnMapView() {
        if (self.rental.geoLocation.latitude != 0) {
            mapView.removeAnnotations(mapView.annotations)
            
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: rental.geoLocation.latitude, longitude:rental.geoLocation.longitude)
            annotation.coordinate = centerCoordinate
            annotation.title = self.rental.name
            mapView.addAnnotation(annotation)
            
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: centerCoordinate, span: span)
            mapView.region = region
        }
    }
    
    @IBAction func onNumberOfRoomsChanged(_ sender: UIStepper) {
        self.numberOfRoomsField.text = "\(Int(sender.value))"
    }
    
    @IBAction func onDelete(_ sender: Any) {
     
        let alert = UIAlertController(title: "Confirm", message: "Are you sure that you want to delete this rental? This action can not undo.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete this Rental", style: .destructive, handler: { (action) in
            SVProgressHUD.show()
            self.rental.deleteInBackground(block: { (success, error) in
                SVProgressHUD.dismiss()
                
                NotificationCenter.default.post(name: NSNotification.Name(AppNotification.RentalInfoChanged.rawValue), object: nil)
                
                self.navigationController?.popViewController(animated: true)
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.navigationController?.present(alert, animated: true, completion: {
            
        })
        
    }
    @IBAction func onSave(_ sender: Any) {
 
        var errors : [String] = []
        
        if self.nameLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errors.append("name is required")
        }
        
        if self.addressLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errors.append("address is required")
        }
        
        if errors.count == 0 {

            
            self.rental.name = self.nameLabel.text!
            self.rental.address = self.addressLabel.text!
            self.rental.features = self.featuresLabel.text!
            self.rental.floorSize = Int(self.floorAreaSizeField.text!) ?? 0
            self.rental.numberOfRooms = Int(self.numberOfRoomsField.text!) ?? 0
            self.rental.pricePerMonth = Int(self.pricePerMonthField.text!) ?? 0
          
            let newStatus = RentalStatus(rawValue: self.statusSwitcher.selectedSegmentIndex) ?? .draft
            if  (self.rental.status != newStatus && newStatus == .available) {
                self.rental.publishedAt = Date()
            }
            self.rental.status = newStatus
            
            self.rental.realtor = self.realtorCell.user
            
            SVProgressHUD.show()
            self.rental.saveInBackground(block: { (success, error) in
                SVProgressHUD.dismiss()
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }
                
                if success {
                   
                    
                    NotificationCenter.default.post(name: NSNotification.Name(AppNotification.RentalInfoChanged.rawValue), object: nil)
                    
                     self.navigationController?.popViewController(animated: true)
                }
            })
                    
            
                
            
        }else{
            showError(message: errors.joined(separator: "\n"))
        }
        
    }
    
    func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.destination.isKind(of: RealtorPickerViewController.self) {
            if let vc = segue.destination as? RealtorPickerViewController,
                let cell = sender as? UserCell {
                vc.realtorSelected = cell.user
                vc.delegate = self
            }
            
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "pickLocation" || identifier == "pickLocationFromMap" ) {
            let locationPicker = LocationPicker()
            if self.addressLabel.text!.count > 0 {
                locationPicker.searchBar.text = self.addressLabel.text
            
                locationPicker.searchBar(locationPicker.searchBar, textDidChange: locationPicker.searchBar.text!)
                
                locationPicker.preselectedIndex = 1
            }
            locationPicker.pickCompletion = { (pickedLocationItem) in
                // Do something with the location the user picked.
                
                self.addressLabel.text = pickedLocationItem.name + " " + pickedLocationItem.formattedAddressString!
                
                if let coordinate = pickedLocationItem.coordinate {
                    self.rental.geoLocation = PFGeoPoint(latitude:  coordinate.latitude, longitude:     coordinate.longitude)
                    
                    self.addPinOnMapView()
                }
                
                
            }
            navigationController!.pushViewController(locationPicker, animated: true)
            
            return false
        }
        
        if identifier == "pickNewFrontImage" {
            var config = YPImagePickerConfiguration()
            config.startOnScreen = YPPickerScreen.photo
            config.screens = [.library, .photo]
            config.showsFilters = false
            
            let picker = YPImagePicker(configuration: config)
            
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    
                    self.saveNewFrontImage(image: photo.image)
                    
                }
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
            
            return false
        }
        return true
    }

    func saveNewFrontImage(image: UIImage) {
        guard let data = image.pngData() else {
            return
        }
        // TODO: resize avatar to smaller size.
        
        self.rental.frontImage = PFFileObject(data: data)
        self.frontImageView.image = image
    }
            
       
}

extension RentalDetailsAdminViewController : RealtorPickerViewControllerDelegate {
    func onRealorSelected(realtor: PFUser) {
        self.realtorCell.user = realtor
    }
}
