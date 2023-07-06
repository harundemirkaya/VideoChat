//
//  MapViewController.swift
//  VideoChat
//
//  Created by Harun Demirkaya on 6.07.2023.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // MARK: -Define
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.delegate = self
        mapView.overrideUserInterfaceStyle = .dark
        return mapView
    }()

    // MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    
    // MARK: -Functions
    private func setupViews(){
        view.backgroundColor = .white
        
        mapView.mapViewConstraints(view)
    }
}

private extension UIView{
    func mapViewConstraints(_ view: UIView){
        view.addSubview(self)
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension MapViewController: MKMapViewDelegate{
    
}
