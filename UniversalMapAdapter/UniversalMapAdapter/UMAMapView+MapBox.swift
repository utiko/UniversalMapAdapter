//
//  UMAMapView+MapBox.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/31/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import Foundation


extension UMAMapView {
    override func mapBoxLayoutSubview() {
        mapViewMB.frame = self.bounds
        self.cleanupMapViews()
    }
}
