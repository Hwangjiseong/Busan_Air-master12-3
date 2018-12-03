//
//  Airdata.swift
//  Busan_Air
//
//  Created by D7703_03 on 2018. 12. 1..
//  Copyright © 2018년 D7703_03. All rights reserved.
//

import Foundation
import MapKit

class Airdata: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var pm10: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, pm10: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.pm10 = pm10
    }
}

