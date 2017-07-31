//
//  UMATestViewController.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/29/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import UIKit

class UMATestViewController: UIViewController {

    @IBOutlet weak var mapView: UMAMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.mapProvider = .mapKit
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func settingsPressed(_ sender: UIBarButtonItem) {
        let popup = UIAlertController(title: nil, message: "Change map provider", preferredStyle: .actionSheet)
        popup.popoverPresentationController?.barButtonItem = sender
        popup.addAction(UIAlertAction(title: "MapKit", style: .default, handler: { action in
            self.mapView.mapProvider = .mapKit
        }))
        popup.addAction(UIAlertAction(title: "GoogleMaps", style: .default, handler: { action in
            self.mapView.mapProvider = .googleMap
        }))
        popup.addAction(UIAlertAction(title: "MapBox", style: .default, handler: { action in
            self.mapView.mapProvider = .mapBox
        }))
        self.present(popup, animated: true, completion: nil)
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
