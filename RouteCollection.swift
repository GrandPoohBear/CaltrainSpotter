//
//  RouteCollection.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation
import MapKit

class RouteCollection : NSObject {
    var routes = [String:RouteModel]()
    
    func parseFromFile() {
        let csvURL = NSBundle.mainBundle().URLForResource("shapes", withExtension: "txt")
        var error: NSErrorPointer = nil
        let csv = CSV(contentsOfURL: csvURL!, error: error)
        
        let rows = csv?.rows
        
        var lastRouteName = ""
        var currentRoute = RouteModel()
        
        for rowDict in rows! {
            // If the route name is different than what we were doing last, we must be on a new one
            // add the old one to the collection, and make a new one to start with
            var shapeId = rowDict["shape_id"]!.stringByReplacingOccurrencesOfString("\"", withString: "")
            
            if (shapeId != lastRouteName) {
                if (currentRoute.name != nil) {
                    routes[currentRoute.name] = currentRoute
                    println("Added \(currentRoute.name) with \(currentRoute.points.count) points.")
                }
                currentRoute = RouteModel()
                currentRoute.name = shapeId
                lastRouteName = shapeId
            }
            
            var shapePtLat = rowDict["shape_pt_lat"]!.stringByReplacingOccurrencesOfString("\"", withString: "")
            var shapePtLon = rowDict["shape_pt_lon"]!.stringByReplacingOccurrencesOfString("\"", withString: "")
            
            let lat = (shapePtLat as NSString).doubleValue
            let lon = (shapePtLon as NSString).doubleValue
            
            currentRoute.addPoint(lat: lat, lon: lon)
        }
        
        //Make sure we add the last one we created
        routes[currentRoute.name] = currentRoute
        println("Added \(currentRoute.name) with \(currentRoute.points.count) points.")
    }
    
    func getCoordinateRegion() -> MKCoordinateRegion {
        
        var minLat:Double = 100000000000
        var minLon:Double = 100000000000
        var maxLat:Double = -100000000000
        var maxLon:Double = -100000000000
        
        for (name, routeModel) in routes {
            var latSorted = sorted(routeModel.points, { (p1:MKMapPoint, p2:MKMapPoint) -> Bool in
                return p1.x < p2.x
            })
            
            var lonSorted = sorted(routeModel.points, { (p1:MKMapPoint, p2:MKMapPoint) -> Bool in
                return p1.y < p2.y
            })
            
            if (latSorted.first!.x < minLat) {
                minLat = latSorted.first!.x
            }
            if (latSorted.last!.x > maxLat) {
                maxLat = latSorted.last!.x
            }
            
            if (lonSorted.first!.y < minLon) {
                minLon = lonSorted.first!.y
            }
            if (lonSorted.last!.x > maxLon) {
                maxLon = lonSorted.last!.y
            }

        }
        
        var midLat = CLLocationDegrees((minLat + maxLat) / 2.0)
        var deltaLat = CLLocationDegrees(maxLat - minLat)
        
        var midLon = CLLocationDegrees((minLon + maxLon) / 2.0)
        var deltaLon = CLLocationDegrees(maxLon - minLon)
        
        var span = MKCoordinateSpanMake(deltaLat, deltaLon)
        
        var centerCoord = CLLocationCoordinate2DMake(midLat, midLon)
        
        return MKCoordinateRegionMake(centerCoord, span)
    }
}