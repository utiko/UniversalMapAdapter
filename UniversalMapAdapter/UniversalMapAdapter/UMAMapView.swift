//
//  UMAMapView.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/29/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import UIKit

import MapKit
import Mapbox
import GoogleMaps

enum UMAMapProvider {
    case mapKit
    case googleMap
    case mapBox
}


class UMAMapViewBase: UIView {
    fileprivate dynamic func mapKitLayoutSubview() { }
    fileprivate dynamic func googleMapsLayoutSubview() {}
    fileprivate dynamic func mapBoxLayoutSubview() {}
}

class UMAMapView: UMAMapViewBase {
    public weak var delegate: UMAMapViewDelegate?
    
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

    fileprivate var mapViewMK: MKMapView?
    fileprivate var mapViewGM: GMSMapView?
    fileprivate var mapViewMB: MGLMapView?

    
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
    
    private var _annotations: Array <UMAMapViewAnnotation> = []
    private var _annptationIDs: Set <String> = []
    
    public var annotations: Array<UMAMapViewAnnotation> {
        get {
            return _annotations
        }
    }
    
    public func addAnnotation(_ annotation: UMAMapViewAnnotation) {
        self.addSingleAnnotation(annotation)
        self.annotationsDidChange()
    }
    
    public func addAnnotations(_ annotations: [UMAMapViewAnnotation]) {
        for annotation in annotations {
            self.addSingleAnnotation(annotation)
        }
        self.annotationsDidChange()
    }
    
    private func addSingleAnnotation(_ annotation: UMAMapViewAnnotation) {
        if let annotationID = annotation.uniqueID {
            if _annptationIDs .contains(annotationID) {
                return
            }
        }
    }
    
    private func annotationsDidChange() {
        
    }
    
    // MARK: Visible region

    public var zoomLevel: Float {
        get {
            switch mapProvider {
            case .mapKit:
                if self.mapViewMK != nil {
                    return log2(360 * (Float(self.mapViewMK!.frame.size.width/256) / Float(self.mapViewMK!.region.span.longitudeDelta)));
                }
            case .googleMap:
                if self.mapViewGM != nil {
                    return self.mapViewGM!.camera.zoom
                }
            case .mapBox:
                if self.mapViewMB != nil {
                    return Float(self.mapViewMB!.zoomLevel + 1.0)
                }
            }
            return 1.0
        }
    }
    
    public var centerCoordinate: CLLocationCoordinate2D {
        get {
            switch mapProvider {
            case .mapKit:
                if self.mapViewMK != nil {
                    return self.mapViewMK!.centerCoordinate;
                }
            case .googleMap:
                if self.mapViewGM != nil {
                    return self.mapViewGM!.camera.target;
                }
            case .mapBox:
                if self.mapViewMB != nil {
                    return self.mapViewMB!.centerCoordinate;
                }
            }
            return CLLocationCoordinate2DMake(0, 0)
        }
    }
    
    public func setCenter(centerCoordinate: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool) {
        switch mapProvider {
        case .mapKit:
            if self.mapViewMK != nil {
                let span = MKCoordinateSpanMake(0, Double(360/pow(2, zoomLevel) * Float(self.frame.size.width/256)))
                let region  = MKCoordinateRegion(center: centerCoordinate, span: span)
                self.mapViewMK?.setRegion(region, animated: animated)
            }
            self.mapViewMK?.setCenter(centerCoordinate, animated: animated)
        case .googleMap:
            if self.mapViewGM != nil{
                if animated {
                    self.mapViewGM!.animate(to: GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: zoomLevel))
                } else {
                    self.mapViewGM!.camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: zoomLevel)
                }
            }
        case .mapBox:
            self.mapViewMB?.setCenter(centerCoordinate, zoomLevel:Double(zoomLevel - 1), animated: animated)
        }
    }

    public func setCenter(centerCoordinate: CLLocationCoordinate2D, animated: Bool) {
        switch mapProvider {
        case .mapKit:
            self.mapViewMK?.setCenter(centerCoordinate, animated: animated)
        case .googleMap:
            if self.mapViewGM != nil{
                if animated {
                    self.mapViewGM!.animate(toLocation: centerCoordinate)
                } else {
                    self.mapViewGM!.camera = GMSCameraPosition.camera(withTarget: centerCoordinate, zoom: self.mapViewGM!.camera.zoom)
                }
            }
        case .mapBox:
            self.mapViewMB?.setCenter(centerCoordinate, animated: animated)
        }
    }
    
}




// MARK: MapKit
extension UMAMapView {
    
    override func mapKitLayoutSubview() {
        if mapViewMK == nil {
            mapViewMK = MKMapView()
            self.addSubview(mapViewMK!)
        }
        mapViewMK?.frame = self.bounds
        
        if mapViewGM != nil {
            mapViewGM?.removeFromSuperview()
            mapViewGM = nil
        }
        if mapViewMB != nil {
            mapViewMB?.removeFromSuperview()
            mapViewMB = nil
        }
    }
}

// MARK: GoogleMaps
extension UMAMapView {
    override func googleMapsLayoutSubview() {

        if mapViewGM == nil {
            mapViewGM = GMSMapView()
            self.addSubview(mapViewGM!)
        }
        mapViewGM?.frame = self.bounds
        
        if mapViewMK != nil {
            mapViewMK?.removeFromSuperview()
            mapViewMK = nil
        }
        if mapViewMB != nil {
            mapViewMB?.removeFromSuperview()
            mapViewMB = nil
        }
    }
}

// MARK: MapBox
extension UMAMapView {
    override func mapBoxLayoutSubview() {
        if mapViewMB == nil {
            mapViewMB = MGLMapView()
            self.addSubview(mapViewMB!)
        }
        mapViewMB?.frame = self.bounds
        
        if mapViewMK != nil {
            mapViewMK?.removeFromSuperview()
            mapViewMK = nil
        }
        if mapViewGM != nil {
            mapViewGM?.removeFromSuperview()
            mapViewGM = nil
        }
    }
}


protocol UMAMapViewDelegate: class {
    
}

protocol UMAMapViewAnnotation {
    var coordinate: CLLocationCoordinate2D { get set }
    var uniqueID: String? { get set }
}

