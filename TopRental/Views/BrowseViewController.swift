//
//  BrowseViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-19.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import Parse
import WYPopoverController

class BrowseViewController: UIViewController {

    @IBOutlet var viewSwitcher: UISegmentedControl!
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var popoverControlelr: WYPopoverController?
    
    var rentals: [Rental] = []
    
    var numberOfRoomsFilter: Int = 0
    var floorSizeFilter: Int = 0
    var priceFilter: Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.titleView = self.viewSwitcher
        
        loadData()
        
        onViewTypeChanges(self.viewSwitcher)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(AppNotification.RentalInfoChanged.rawValue), object: nil, queue: nil) { (notif) in
            
            self.loadData()
        }
    }
    
    func loadData() {
    
        let query = PFQuery(className: "Rental")
        query.whereKey("status", equalTo: RentalStatus.available.rawValue)
        query.includeKeys(["realtor"])
        query.cachePolicy = .cacheThenNetwork
        
        
        if numberOfRoomsFilter > 0 {
            query.whereKey("numberOfRooms", equalTo: numberOfRoomsFilter)
        }
        
        let floorSizeRange = FilterSettings.floorSizeRanges[floorSizeFilter]
        query.whereKey("floorSize", greaterThanOrEqualTo: floorSizeRange.0)
        query.whereKey("floorSize", lessThan: floorSizeRange.1)

        let priceRange = FilterSettings.pricePerMonthRanges[priceFilter]
        query.whereKey("pricePerMonth", greaterThanOrEqualTo: priceRange.0)
        query.whereKey("pricePerMonth", lessThan: priceRange.1)
        

        query.findObjectsInBackground { (objects, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if let objects = objects {
                self.rentals = objects as! [Rental]
                self.tableView.reloadData()
                
                self.plotPinsOnMap()
            }
        }
    }
    
    func plotPinsOnMap() {
        mapView.removeAnnotations(mapView.annotations)
        
        for rental in self.rentals {
            let annotation = RentalAnnotaion()
            let centerCoordinate = CLLocationCoordinate2D(latitude: rental.geoLocation.latitude, longitude:rental.geoLocation.longitude)
            annotation.coordinate = centerCoordinate
            annotation.title = rental.name
            annotation.subtitle = rental.address
            annotation.rental = rental
            mapView.addAnnotation(annotation)
            
        }
        
        mapView.showAnnotations(self.mapView.annotations, animated: true)

        
//        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
//        mapView.region = region
    }

    @IBAction func onViewTypeChanges(_ sender: UISegmentedControl) {
        
        let isInMapMode = self.viewSwitcher.selectedSegmentIndex == 0
        
        self.mapView.isHidden = !isInMapMode
        self.tableView.isHidden = isInMapMode
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func onShowFilterView(_ sender: UIBarButtonItem) {
        
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "FilterVC") as! FilterViewController
        
        vc.preferredContentSize = CGSize(width: 320, height: 700)
        vc.delegate = self
        if (popoverControlelr == nil) {
            popoverControlelr = WYPopoverController(contentViewController: vc)
            popoverControlelr?.delegate = self
            
        }
        popoverControlelr?.presentPopover(from: sender, permittedArrowDirections: .up, animated: false, completion: {

        })
 
    }
}

extension BrowseViewController : WYPopoverControllerDelegate {
    func popoverControllerDidDismissPopover(_ popoverController: WYPopoverController!) {
        self.loadData()
    }
}
extension BrowseViewController : FilterViewControllerDelegate {
    
    
    func getCurrentFilter() -> (Int, Int, Int) {
        return (self.numberOfRoomsFilter, self.floorSizeFilter, self.priceFilter)
    }
    
    func setCurrentFilter( _ filters:(Int, Int, Int)) {
        (self.numberOfRoomsFilter, self.floorSizeFilter, self.priceFilter) = filters
        
    }
}

extension BrowseViewController : UITabBarDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rentals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RentalCell", for: indexPath) as! RentalCell
        
        guard cell.isKind(of: RentalCell.self) else {
            fatalError()
        }
        
        cell.delegate = self
        cell.rental = self.rentals[indexPath.row]
        
        return cell
        
    }
}

extension BrowseViewController : RentalCellDelegate {
    func onLocationRentalOnMap(rental: Rental) {
        self.viewSwitcher.selectedSegmentIndex = 0
        self.onViewTypeChanges(self.viewSwitcher)
        
        if let rentalAnn = self.mapView.annotations.first(where: { (annotation) -> Bool in
            if annotation.isKind(of: RentalAnnotaion.self)  {
                return (annotation as! RentalAnnotaion).rental.objectId == rental.objectId
            }
            return false
        }) {
            self.mapView.selectAnnotation(rentalAnn, animated: true)
        }
        
    }
    
    func onBookingAppointment(rental: Rental) {
        guard let realtor = rental.realtor else {
            print("Rental has no reator associated")
            return
        }
        
        PFCloud.callFunction(inBackground: "fetchUser",
                             withParameters: ["userId": realtor.objectId as Any])
        { (result, error) in
            if let result = result as? Dictionary<String, Any>,
                let user = result["user"] as? PFUser,
                let email = user.email {
                
                self.presentEmailComposerForRental(realtorEmail: email, rental: rental)
            }
        }
        
        
    }
    
    func presentEmailComposerForRental(realtorEmail: String, rental: Rental) {
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients([realtorEmail])
        composeVC.setSubject("Hello! I would like to book an appointment")
        composeVC.setMessageBody("Reantal: \(rental.address)" , isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
}

extension BrowseViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController,
                               didFinishWithResult result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

extension BrowseViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl){
        
        guard let rentalAnnotation = view.annotation as? RentalAnnotaion else {
            return
        }
        
        guard let idx = self.rentals.map({ (rental) -> String in
            rental.objectId!
        })
            .firstIndex(of: rentalAnnotation.rental.objectId) else{
            print("rental pin not found")
            return
        }
        
        
        self.viewSwitcher.selectedSegmentIndex = 1
        self.onViewTypeChanges(self.viewSwitcher)
        
 
        self.tableView.selectRow(at: IndexPath(row: idx, section: 0), animated: true, scrollPosition: .top)
        
    }
}

class RentalAnnotaion : MKPointAnnotation {
    var rental: Rental! = Rental()
}
