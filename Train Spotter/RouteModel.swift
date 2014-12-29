//
//  RouteModel.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation
import MapKit

class RouteModel : NSObject {
    var name:String!
    var points:[MKMapPoint] = [MKMapPoint]()
    
    func addPoint(#lat:Double, lon: Double) {
        points.append(MKMapPointMake(lat, lon))
    }
    
    func toPolyLine() -> MKPolyline {
        var locations = [CLLocationCoordinate2D]()
        for point in points {
            var lat = point.x
            var lon = point.y
            var location = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
            locations.append(location)
        }
        return MKPolyline(coordinates: &locations, count: locations.count)
    }
}