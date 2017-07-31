//
//  PrivateKeyService.swift
//  UniversalMapAdapter
//
//  Created by Kostia Kolesnyk on 7/31/17.
//  Copyright © 2017 Kostia Kolesnyk. All rights reserved.
//

import Foundation

class PrivateKeyService {
    static func privateKeyByTitle(_ keyID: String) -> String {
        if let path = Bundle.main.path(forResource: "private-keys", ofType: "plist") {
            let keys = NSDictionary(contentsOfFile: path)
            if let keys = keys {
                if let key = keys[keyID] as? String {
                    return key
                }
            }
        }
        print("Error getting key for \(keyID)")
        return ""
    }
}

