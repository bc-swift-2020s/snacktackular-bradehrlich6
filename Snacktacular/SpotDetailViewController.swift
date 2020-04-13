//
//  SpotDetailViewController.swift
//  Snacktacular
//
//  Created by John Gallaugher on 3/23/18.
//  Copyright © 2018 John Gallaugher. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit
import Contacts

class SpotDetailViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var averageRatingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    var spot: Spot!
    let regionDistance: CLLocationDistance = 750
    let locationManager: CLLocationManager!
    var currentLocation: CLLocation

    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView.delegate = self
        
        if spot == nil{
            spot = Spot()
            getLocation()
        }
        
        
        let region = MKCoordinateRegion(center: spot.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        mapView.setRegion(region, animated: true)
        
        updateUserInterface()
    }
    
    func updateUserInterface() {
        nameField.text = spot.name
        addressField.text = spot.address
        updateMap()
    }
    
    func updateMap () {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(spot)
        mapView.setCenter(spot.coordinate, animated: true)
    }
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func photoButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        spot.name = nameField.text!
        spot.address = addressField.text!
        spot.saveData { success in
            if success{
                self.leaveViewController()
            }else {
                print("Error")
            }
            
        }
    }
    
    @IBAction func lookupPlacePressed(_ sender: UIBarButtonItem) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        
        present(autocompleteController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
}
extension SpotDetailViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    spot.name = place.name ?? ""
    spot.address = place.formattedAddress ?? ""
    spot.coordinate = place.coordinate
    dismiss(animated: true, completion: nil)
    updateUserInterface()
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: ", error.localizedDescription)
  }

  // User canceled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }

}
extension SpotDetailViewController: CLLocationManagerDelegate {
    func getLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus){
        switch status{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways,.authorizedWhenInUse:
            locationManager.requestLocation()
        case .denied:
            showAlertToPrivacySettings(title: "Need Location Access", message: "Need Location Access")
        case .restricted:
            print("Error")
        }
    }
    
    func showAlertToPrivacySettings(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        guard let settingsURL = URL(string: UIApplicationOpenSettingsURLString) else {
            print("Something is wrong")
            return
        }
        let settingsActions = UIAlertAction(title: "Settings", style: .default) { value in UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil) }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(settingsActions)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard spot.name == "" else{
            return
        }
        let geoCoder = CLGeocoder()
        var name = ""
        var address = ""
        currentLocation = locations.last
        spot.coordinate = currentLocation?.coordinate
        geoCoder.reverseGeocodeLocation(currentLocation) {placemarks, error in
            if placemarks != nil{
                let placemark = placemarks?.last
                name = placemark?.name ?? "name unknown"
                
                if let postalAddress = placemark?.postalAddress{
                    address = CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                }
            } else{
                print("Error")
            }
            self.spot.name = name
            self.spot.address = address
            self.updateUserInterface()
        }
    }
}
