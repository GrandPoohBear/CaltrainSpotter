//
//  GeoUtilities.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/29/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation
import MapKit

class GeoUtilities : NSObject {
    
    class func isCoordinateWithinRegion(coord: CLLocationCoordinate2D, region: MKCoordinateRegion, mapView: MKMapView) -> Bool {
        var rect = mapView.convertRegion(region, toRectToView: nil)
        var point = mapView.convertCoordinate(coord, toPointToView: nil)
        
        return rect.contains(point)
    }
    
}