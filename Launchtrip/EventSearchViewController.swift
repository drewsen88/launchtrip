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

class EventSearchViewController: UIViewController {
    
    private var placemarkSelected: Bool = false
    var attributes: EKAttributes! = nil
    
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
        greeting.text = "What event are you attending?"
        greeting.font = UIFont.boldSystemFont(ofSize: 25)
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
        self.view.addSubViews([mapView, btnLocate, maskView, searchResultsView, searchbar, greeting])
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
                               multiplier: 1.0, constant: 0.25*self.dim.height),
            NSLayoutConstraint(item: greeting as Any, attribute: .centerX,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .centerX,
                               multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: searchbar as Any, attribute: .top,
                               relatedBy: .equal,
                               toItem: self.view, attribute: .top,
                               multiplier: 1.0, constant: 0.33*self.dim.height),
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
        
        greeting.setHeightConstraint(0.07*dim.height)
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
                        let title = "No Results Found"
                        let desc = "Enter your email and be notified of future updates"
                        let image = "ic_locate"
                        self.showNotificationMessage(attributes: self.attributes, title: title, desc: desc, textColor: .white, imageName: image)
                        
                    }

                    self.searchResultsView.update(newPlacemarks: placemarks, error: error)
                    completion?(placemarks, error)
                }
            }
        }
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
                let eventCollectionViewController = TodayCollectionViewController()
                if let navigator = self?.navigationController {
                    navigator.pushViewController(eventCollectionViewController, animated: true)
                }

            })
            
            placemarkSelected = false
            
        }

    }
    
}
