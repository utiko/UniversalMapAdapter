//
//  UMAMapView+MapKit.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/31/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import Foundation
import MapKit


extension UMAMapView: MKMapViewDelegate {
    
    var mapViewMK: MKMapView {
        get {
            if let mapViewMK = _mapViewMK as? MKMapView {
                return mapViewMK
            }
            
            let mapViewMK = MKMapView()
            self.addSubview(mapViewMK)
            _mapViewMK = mapViewMK
            return mapViewMK
        }
    }

    
    override func mapKitLayoutSubview() {
        mapViewMK.frame = self.bounds
        self.cleanupMapViews()
    }
    
    public func setCenterMK(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool) {
        let span = MKCoordinateSpanMake(0, Double(360/pow(2, zoomLevel) * Float(self.frame.size.width/256)))
        let region  = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapViewMK.setRegion(region, animated: animated)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationAdapter = annotation as? UMAMapKitAnnotationAdaper {
            let annotationView = self.delegate?.mapView(self, viewFor: annotationAdapter.annotation)
            if let annotationView = annotationView {
                let annotationViewAdapter = UMAMapKitAnnotationViewAdapter(annotationView: annotationView, annotationAdapter: annotationAdapter)
                return annotationViewAdapter
            }
        }
        return nil
    }
}



class UMAMapKitAnnotationAdaper: NSObject, MKAnnotation {
    
    init(annotation: UMAAnnotation) {
        self.annotation = annotation
    }
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return self.annotation.coordinate
        }
    }
    var annotation: UMAAnnotation
    
}

class UMAMapKitAnnotationViewAdapter: MKAnnotationView {
    
    init(annotationView: UMAAnotationView, annotationAdapter: UMAMapKitAnnotationAdaper) {
        self.annotationView = annotationView
        self.annotationView.frame = self.annotationView.bounds
        self.annotationView = annotationView
        super.init(annotation: annotationAdapter, reuseIdentifier: annotationView.reuseIdentifier)

        self.addSubview(self.annotationView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var annotationView: UMAAnotationView
    
    override var reuseIdentifier: String? {
        return self.annotationView.reuseIdentifier
    }
    
}

