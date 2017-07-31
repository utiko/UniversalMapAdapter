//
//  MapBoxTryViewController.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/29/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import UIKit
import Mapbox

class MapBoxTryViewController: UIViewController {

    @IBOutlet weak var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.allowsRotating = false;
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
