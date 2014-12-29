//
//  StopCollection.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation
import MapKit

class StopCollection : NSObject {
    var stops = [String:StopModel]()
    var northboundStops = [String:StopModel]()
    var southboundStops = [String:StopModel]()
    
    func parseFromFile() {
        let csvURL = NSBundle.mainBundle().URLForResource("stops", withExtension: "txt")
        var error: NSErrorPointer = nil
        let csv = CSV(contentsOfURL: csvURL!, error: error)
        
        let rows = csv?.rows

        // Since the "parent" stops are at the end of the file, scan for those first,
        // then go back through and fill in the northbound/southbound locations
        
        for rowDict in rows! {
            if (rowDict["stop_id"]!.hasPrefix("ct")) {
                var stop = StopModel()
                stop.name = rowDict["stop_name"]
                stop.generalStopId = rowDict["stop_id"]
                
                var lat = (rowDict["stop_lat"]! as NSString).doubleValue
                var lon = (rowDict["stop_lon"]! as NSString).doubleValue
                
                var coord = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
                stop.generalLocation = coord
                
                stops[stop.generalStopId] = stop
            }
        }
        
        // Second pass, just fill in the northbound/southbound bits
        
        for rowDict in rows! {
            if (!rowDict["stop_id"]!.hasPrefix("ct")) {
                var stopId = rowDict["stop_id"]
                var parentStopId = rowDict["parent_station"]
                var stop = stops[parentStopId!]
                
                if (stop != nil) {
                    var lat = (rowDict["stop_lat"]! as NSString).doubleValue
                    var lon = (rowDict["stop_lon"]! as NSString).doubleValue
                    
                    var coord = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
                    
                    var direction = rowDict["platform_code"]
                    if (direction == "NB") {
                        stop?.northboundLocation = coord
                        northboundStops[stopId!] = stop
                    } else if (direction == "SB") {
                        stop?.southboundLocation = coord
                        southboundStops[stopId!] = stop
                    } else {
                        println("Direction was something other than NB/SB")
                    }
                } else {
                    println("Couldn't find the corresponding general stop for \(parentStopId)")
                }
            }
        }
    }
}