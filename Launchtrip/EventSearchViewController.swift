//
//  EventSearchViewController.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-08-15.
//  Copyright © 2019 Drew Sen. All rights reserved.
//

import UIKit
import MapKit
import SwiftEntryKit
import Alamofire
import Intents
import Contacts


public struct EventCenter: Codable {
    
    var city: String
    var country: String
    var id: String
    
    var lat: String
    var lon: String

    var name: String
    var state: String
    var streetAddress: String

}


public struct EventLandmark: Codable {
    // Double, String, and Int all conform to Codable.
    var ends: String?
    
    // Adding a property of a custom Codable type maintains overall Codable conformance.
    var eventCenter: EventCenter

    var id: String
    var instanceName: String
    var name: String
    var starts: String?
    var timezone: String
    
}

class EventSearchViewController: UIViewController {
    
    private var placemarkSelected: Bool = false
    var attributes: EKAttributes! = nil
    
    public lazy var firstName: String = ""
    
    // MARK: - UI widgets
    private var greeting: UITextView!
    private var searchbar: Searchbar!
    private var maskView: UIImageView!
    private var searchResultsView: SearchResultsView!
    private var mapView: MKMapView!
    private var btnLocate: MaterialButton!
    // MARK: - Private properties
    private var dim: CGSize = .zero
    private let animHplr = AnimHelper.shared
    
    private var foundPlacemarks = [CLPlacemark]()
    private var eventLandmarks = [EventLandmark]()
    // viewDidLoad
    override func viewDidLoad() {
        
        super.viewDidLoad()
        dim = self.view.frame.size
        initUI()
        requestPermission()
        btnLocate.addTarget(self, action: #selector(tapLocate), for: .touchUpInside)
        
    }
    /**
     Init UI.
     */
    private func initUI() {
        self.view.backgroundColor = ResManager.Colors.sand
        
        setUpErrorPopupAttributes()
        
        maskView = UIImageView()
        maskView.backgroundColor = .white
        
        greeting = UITextView()
        if firstName != ""
        {
            greeting.text = "Hi \(firstName),"
        }
        greeting.text.append("\nWhat event are you attending?") 
        greeting.isEditable = false
        greeting.font = UIFont.boldSystemFont(ofSize: 26)
        greeting.backgroundColor = .clear
        // Configure searchbar
        searchbar = Searchbar(
            onStartSearch: { [weak self] (isSearching) in
                guard let self = self else { return }
                self.showSearchResultsView(isSearching)
            },
            onClearInput: { [weak self] in
                guard let self = self else { return }
                self.searchResultsView.state = .populated([])
                self.mapView.removeAnnotations(self.mapView.annotations)
            },
            delegate: self
        )
        // Configure searchResultsView
        searchResultsView = SearchResultsView(didSelectAction: { [weak self] (placemark) in
            guard let self = self else { return }
            self.didSelectPlacemark(placemark)
        })
        showSearchResultsView(false)
        // Set up mapView
        mapView = MKMapView()
        mapView.delegate = self
        btnLocate = MaterialButton(
            icon: #imageLiteral(resourceName: "ic_locate").colored(.darkGray),
            bgColor: .white,
            cornerRadius: 0.15*dim.width/2,
            withShadow: true
        )
        self.view.addSubViews([mapView, btnLocate, maskView, searchResultsView, greeting, searchbar])
        self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    // Bumps a notification structured entry
    private func showNotificationMessage(attributes: EKAttributes, title: String, desc: String, textColor: UIColor, imageName: String? = nil) {
        let title = EKProperty.LabelContent(text: title, style: .init(font: MainFont.medium.with(size: 16), color: textColor))
        let description = EKProperty.LabelContent(text: desc, style: .init(font: MainFont.light.with(size: 14), color: textColor))
        var image: EKProperty.ImageContent?
        if let imageName = imageName {
            image = .init(image: UIImage(named: imageName)!, size: CGSize(width: 35, height: 35))
        }
        
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)
        
        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    private func requestPermission() {
        appDelegate.locationMgr.desiredAccuracy = kCLLocationAccuracyBest
        appDelegate.locationMgr.requestAlwaysAuthorization()
    }
    
    @objc private func tapLocate() {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func didSelectPlacemark(_ placemark: CLPlacemark) {
        guard let loc = placemark.location else { return }
        
        //Dispatch async transition to events view controller
        // show events view controller
        placemarkSelected = true
        
        if foundPlacemarks.count > 0 {
            let placemarkIndex = foundPlacemarks.firstIndex(of: placemark)!
            eventLandmarks.swapAt(placemarkIndex, 0)
        }

        // Set search bar
        self.searchbar.textInput.text = placemark.name
        self.searchbar.textFieldDidEndEditing(self.searchbar.textInput)
        // Dismiss search results view
        self.showSearchResultsView(false)
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.title = placemark.name
        annotation.coordinate = loc.coordinate
        self.mapView.showAnnotations([annotation], animated: true)
        
    }
    
    private func showSearchResultsView(_ show: Bool) {
        if show {
            guard maskView.alpha == 0.0 else { return }
            animHplr.moveUpViews([maskView, searchResultsView], show: true)
        } else {
            animHplr.moveDownViews([maskView, searchResultsView], show: false)
            searchResultsView.isScrolling = false
        }
    }
    
    private func setUpErrorPopupAttributes()
    {
        attributes = .topFloat
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .gradient(gradient: .init(colors: [.amber, .pinky], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 0.3), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.size.width), height: .intrinsic)
    }
    
    // viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        mapView.setConstraintsToView(top: self.view, bottom: self.view, left: self.view, right: self.view)
        btnLocate.setConstraintsToView(bottom: self.view, bConst: -0.05*dim.height, right: searchbar)
        
        //Searchbar constraints here
        self.view.addConstraints([
            NSLayoutConstraint(item: greeting as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .top,
                               multiplier: 1.0, constant: 0.24*self.dim.height),
            NSLayoutConstraint(item: greeting as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchbar as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .top,
                               multiplier: 1.0, constant: 0.35*self.dim.height),
            NSLayoutConstraint(item: searchbar as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: searchbar, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchResultsView as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: searchbar, attribute: .bottom,
                               multiplier: 1.0, constant: 0.02*dim.height)
            ])
        searchResultsView.setConstraintsToView(bottom: maskView, left: searchbar, right: searchbar)
        searchbar.setHeightConstraint(0.07*dim.height)
        searchbar.setWidthConstraint(0.9*dim.width)
        
        greeting.setHeightConstraint(0.15*dim.height)
        greeting.setWidthConstraint(0.9*dim.width)
        
        // Set the corner radius to be half of the button height to make it circular.
        btnLocate.setHeightConstraint(0.15*dim.width)
        btnLocate.setWidthConstraint(0.15*dim.width)
        self.view.layoutIfNeeded()
    }
    // viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        (mapView.isZoomEnabled, mapView.showsUserLocation) = (true, true)
        mapView.setUserTrackingMode(.follow, animated: true)
        placemarkSelected = false
    }
}
// MARK: - SearchbarDelegate
extension EventSearchViewController: SearchbarDelegate {
    
    func searchbarTextDidChange(_ textField: UITextField) {
        guard let keyword = isTextInputValid(textField) else { return }
        searchResultsView.state = .loading
        searchLocations(keyword)
        //TODO: Add event api request here
//        searchEvents(keyword)
    }
    
    private func isTextInputValid(_ textField: UITextField) -> String? {
        if let keyword = textField.text, !keyword.isEmpty { return keyword }
        return nil
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSearchResultsView(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard !searchResultsView.isScrolling else { return }
        showSearchResultsView(false)
        searchbar.setBtnStates(hasInput: textField.text?.count != 0, isSearching: false)
    }
    
    func searchbarTextShouldReturn(_ textField: UITextField) -> Bool {
        guard let keyword = isTextInputValid(textField) else { return false }
        searchLocations(keyword, completion: { [weak self] (placemarks, error) in
            guard let self = self, let first = placemarks.first else { return }
            self.didSelectPlacemark(first)
        })
//        searchEvents(keyword)
//        if foundPlacemarks.count > 0
//        {
//            self.didSelectPlacemark(foundPlacemarks.first!)
//        }
        return true
    }
    /**
     Search locations by keyword entered in search bar.
     
     - Parameter keyword:    The keyword as the input to search locations.
     - Parameter completion: The completion handler after showing search results.
     */
    private func searchLocations(_ keyword: String, completion: (([CLPlacemark], Error?) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = keyword
            request.region = self.mapView.region
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                var placemarks = [CLPlacemark]()
                if let response = response {
                    for item in response.mapItems {
                        placemarks.append(item.placemark)
                    }
                }
                DispatchQueue.main.async {
                    
                    if error != nil {
                        //Show error pop up message here
                        self.showErrorPopupMessage()
                        
                    }

                    self.searchResultsView.update(newPlacemarks: placemarks, error: error)
                    completion?(placemarks, error)
                }
            }
        }
    }
    
    private func searchEvents (_ keyword: String, completion: (([CLPlacemark], Error?) -> Void)? = nil)
    {
        
        let parameters: Parameters = [
            "name": keyword,
            "sort": "starts",
            "order": "ASC"
        ]


        Alamofire.request(APPURL.EventEndpoint, parameters: parameters).responseJSON { response in
            print("Request: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            print("Result: \(response.result)")                         // response serialization result
            
            if let json = response.result.value {
                print("JSON: \(json)") // serialized json response
            }
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                
                var landMarks: [EventLandmark]
                var newPlacemarks = [CLPlacemark]()
                
                do{
                    //created the json decoder
                    let decoder = JSONDecoder()

                    //using the array to put values
                    landMarks = try decoder.decode([EventLandmark].self, from: data)
                    self.eventLandmarks = landMarks
                    
                    //printing all the hero names
                    for landMark in landMarks{
                        let eventLocation = CLLocation(latitude: (landMark.eventCenter.lat as NSString).doubleValue, longitude: (landMark.eventCenter.lon as NSString).doubleValue)
                        let eventName = landMark.name
                        
                        let postalAddr = CNMutablePostalAddress()
                        postalAddr.street = String(format: "%@", landMark.eventCenter.streetAddress)

                        let event = CLPlacemark.init(location: eventLocation,
                                                  name: eventName,
                                                  postalAddress: nil)
                        newPlacemarks.append(event)
                        print(landMark.name)
                    }
                    
                }catch let err{
                    print(err)
                }
                
                
                if newPlacemarks.count > 0
                {
                    self.foundPlacemarks = newPlacemarks
                    self.searchResultsView.update(newPlacemarks: newPlacemarks, error: nil)

                }
                else{
                    //Show error pop up message here
                    let title = "No Results Found"
                    let desc = "Enter your email and be notified of future updates"
                    let image = "ic_locate"
                    self.showNotificationMessage(attributes: self.attributes, title: title, desc: desc, textColor: .white, imageName: image)
                    

                }

                print("Data: \(utf8Text)") // original server data as UTF8 string
            }
        }

    }
    
    private func showErrorPopupMessage()
    {
        //Show error pop up message here
        let title = "No Results Found"
        let desc = "Enter your email and be notified of future updates"
        let image = "ic_locate"
        self.showNotificationMessage(attributes: self.attributes, title: title, desc: desc, textColor: .white, imageName: image)

    }
    
    
}
// MARK: - MKMapViewDelegate
extension EventSearchViewController: MKMapViewDelegate {
    // viewForAnnotation
    // Refer to https://hackingwithswift.com
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(#function)
        
        if placemarkSelected {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: { [weak self] in
                
                let controller = AirbnbExploreController()
                
                if let navigator = self?.navigationController {
                    navigator.pushViewController(controller, animated: true)
                }

//                if let eventCollectionViewController = UIStoryboard.Main.instantiateViewController(withIdentifier: "EventCollection") as? EventCollectionViewController {
//                    eventCollectionViewController.eventLandmarks = self?.eventLandmarks ?? [EventLandmark]()
//
//                }

            })
            
            placemarkSelected = false
            
        }

    }
    
}
