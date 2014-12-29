//
//  StopModel.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation
import MapKit

class StopModel : NSObject {
    var name: String!
    var generalStopId: String!
    var generalLocation: CLLocationCoordinate2D!
    var southboundStopId: String!
    var southboundLocation: CLLocationCoordinate2D!
    var northboundStopId: String!
    var northboundLocation: CLLocationCoordinate2D!
    
    func toAnnotation() -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.setCoordinate(generalLocation)
        annotation.title = name
        
        return annotation
    }
}