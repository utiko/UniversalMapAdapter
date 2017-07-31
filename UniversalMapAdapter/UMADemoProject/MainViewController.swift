//
//  ViewController.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/29/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import Mapbox




class MainViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// Mark: table view
extension MainViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}

