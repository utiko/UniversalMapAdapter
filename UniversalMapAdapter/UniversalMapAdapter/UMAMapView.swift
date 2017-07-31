//
//  UMAMapView.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/29/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import UIKit

//import MapKit
import Mapbox
import GoogleMaps


enum UMAMapProvider {
    case mapKit
    case googleMap
    case mapBox
}


class UMAMapViewBase: UIView {
    dynamic func mapKitLayoutSubview() { }
    dynamic func googleMapsLayoutSubview() {}
    dynamic func mapBoxLayoutSubview() {}
}

class UMAMapView: UMAMapViewBase {
    public weak var delegate: UMAMapViewDelegate?
    
    
    // MARK: Map provider
    
    private var _mapProvider: UMAMapProvider = .mapKit
    public var mapProvider: UMAMapProvider  {
        get {
            return _mapProvider
        }
        set(val) {
            let oldCenterCoordinate = self.centerCoordinate
            let oldZoom = self.zoomLevel
            _mapProvider = val
            self.layoutSubviews()
            self.setCenter(centerCoordinate: oldCenterCoordinate, zoomLevel: oldZoom, animated: false)
        }
    }

    
    // MARK: Map Views
    var _mapViewMK: UIView?
    
    private var _mapViewGM: GMSMapView?
    var mapViewGM: GMSMapView {
        get {
            if (_mapViewGM == nil) {
                _mapViewGM = GMSMapView()
                self.addSubview(_mapViewGM!)
            }
            return _mapViewGM!
        }
    }
    private var _mapViewMB: MGLMapView?
    var mapViewMB: MGLMapView {
        get {
            if (_mapViewMB == nil) {
                _mapViewMB = MGLMapView()
                self.addSubview(_mapViewMB!)
            }
            return _mapViewMB!
        }
    }

    func cleanupMapViews() {
        if self.mapProvider != .mapKit, _mapViewMK != nil {
            _mapViewMK!.removeFromSuperview()
            _mapViewMK = nil
        }
        if self.mapProvider != .googleMap, _mapViewGM != nil {
            _mapViewGM!.removeFromSuperview()
            _mapViewGM = nil
        }
        if self.mapProvider != .mapBox, _mapViewMB != nil {
            _mapViewMB!.removeFromSuperview()
            _mapViewMB = nil
        }
    }
    
    override func layoutSubviews() {
        switch mapProvider {
        case .mapKit:
            self.mapKitLayoutSubview()
        case .googleMap:
            self.googleMapsLayoutSubview()
        case .mapBox:
            self.mapBoxLayoutSubview()
        }
    }
    
    // MARK: Annotations
    
    private var _annotations: Array <UMAAnnotation> = []
    private var _annptationIDs: Set <String> = []
    
    public var annotations: Array<UMAAnnotation> {
        get {
            return _annotations
        }
    }
    
    public func addAnnotation(_ annotation: UMAAnnotation) {
        self.addSingleAnnotation(annotation)
        self.annotationsDidChange()
    }
    
    public func addAnnotations(_ annotations: [UMAAnnotation]) {
        for annotation in annotations {
            self.addSingleAnnotation(annotation)
        }
        self.annotationsDidChange()
    }
    
    private func addSingleAnnotation(_ annotation: UMAAnnotation) {
        if let annotationID = annotation.uniqueID {
            if _annptationIDs .contains(annotationID) {
                return
            }
        }
    }
    
    private func annotationsDidChange() {
        
    }
    
    // MARK: Customize annotations
    
    public func dequeueReusableAnnotationView(withIdentifier identifier: String) -> UMAAnotationView? {
        switch mapProvider {
        case .mapKit:
            let annotationView = self.mapViewMK.dequeueReusableAnnotationView(withIdentifier: identifier)
            if let annotationViewAdapter = annotationView as? UMAMapKitAnnotationViewAdapter {
                return annotationViewAdapter.annotationView
            }
        case .googleMap:
            self.googleMapsLayoutSubview()
        case .mapBox:
            self.mapBoxLayoutSubview()
        }
        return nil
    }
    
    // MARK: Visible region

    public var zoomLevel: Float {
        get {
            switch mapProvider {
            case .mapKit:
                return log2(360 * (Float(self.mapViewMK.frame.size.width/256) / Float(self.mapViewMK.region.span.longitudeDelta)));
            case .googleMap:
                return self.mapViewGM.camera.zoom
            case .mapBox:
                return Float(self.mapViewMB.zoomLevel + 1.0)
            }
        }
    }
    
    public var centerCoordinate: CLLocationCoordinate2D {
        get {
            switch mapProvider {
            case .mapKit:
                return self.mapViewMK.centerCoordinate;
            case .googleMap:
                return self.mapViewGM.camera.target;
            case .mapBox:
                return self.mapViewMB.centerCoordinate;
            }
        }
    }
    
    public func setCenter(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool) {
        switch mapProvider {
        case .mapKit:
            self.setCenterMK(centerCoordinate: centerCoordinate, zoomLevel: zoomLevel, animated: animated)
        case .googleMap:
            if animated {
                self.mapViewGM.animate(to: GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: zoomLevel))
            } else {
                self.mapViewGM.camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: zoomLevel)
            }
        case .mapBox:
            self.mapViewMB.setCenter(centerCoordinate, zoomLevel:Double(zoomLevel - 1), animated: animated)
        }
    }

    public func setCenter(centerCoordinate: CLLocationCoordinate2D, animated: Bool) {
        switch mapProvider {
        case .mapKit:
            self.mapViewMK.setCenter(centerCoordinate, animated: animated)
        case .googleMap:
            if animated {
                self.mapViewGM.animate(toLocation: centerCoordinate)
            } else {
                self.mapViewGM.camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: self.mapViewGM.camera.zoom)
            }
        case .mapBox:
            self.mapViewMB.setCenter(centerCoordinate, animated: animated)
        }
    }
    
}






protocol UMAMapViewDelegate: class {
    
    func mapView(_ mapView: UMAMapView, viewFor annotation: UMAAnnotation) -> UMAAnotationView
    
}

/*protocol UMAMapViewClusteringDelegate: class {
    
    func mapView(_ mapView: UMAMapView, imageFor cluster: UMAClusterAnnotation)
    
}*/

protocol UMAAnnotation {
    var coordinate: CLLocationCoordinate2D { get set }
    var uniqueID: String? { get set }
}


/*class UMAClusterAnnotation: UMAAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var uniqueID: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
}*/


class UMAAnotationView: UIView {

    var annotation: UMAAnnotation
    var reuseIdentifier: String?

    init(annotation: UMAAnnotation) {
        self.annotation = annotation
        super.init(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    }
    
    init(annotation: UMAAnnotation, reuseIdentifier: String?) {
        self.annotation = annotation
        self.reuseIdentifier = reuseIdentifier
        super.init(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    public var image: UIImage? {
        get {
            return self.imageView?.image
        }
        set (image) {
            
            if (image == nil) {
                if let imageView = self.imageView {
                    imageView.image = nil
                    imageView.removeFromSuperview()
                    self.imageView = nil
                }
                return
            }
            
            if (self.imageView == nil) {
                self.imageView = UIImageView()
                self.addSubview(self.imageView!)
            }
            
            self.imageView?.image = image
            self.imageView?.sizeToFit()
            self.frame = self.imageView!.bounds
            
        }
    }
    private var imageView: UIImageView?
}





