//
//  ScheduleUtilities.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation
import MapKit

class ScheduleUtilities : NSObject {
    class func determinePosition(schedule : ScheduleModel, weekDay: Int, curTimeInSecs : Double, stops : StopCollection) -> CLLocationCoordinate2D? {
        
        if schedule.dayType == ScheduleModel.ScheduleType.UNSET {
            return nil
        }
        
        // First determine if this is the correct day for the schedule
        if weekDay == 1 {   // Sunday
            if schedule.dayType == ScheduleModel.ScheduleType.SATURDAY || schedule.dayType == ScheduleModel.ScheduleType.WEEKDAY {
                return nil
            }
        } else if weekDay == 7 { // Saturday
            if schedule.dayType == ScheduleModel.ScheduleType.SUNDAY || schedule.dayType == ScheduleModel.ScheduleType.WEEKDAY {
                return nil
            }
        } else { // Weekday
            if schedule.dayType == ScheduleModel.ScheduleType.SATURDAY || schedule.dayType == ScheduleModel.ScheduleType.SUNDAY {
                return nil
            }
        }
        
        // Scan through schedule, get the last time that is before curTime
        // Also grab the first time after
        var departingTime = 0.0
        var departingStopId = ""
        var departingLocation: CLLocationCoordinate2D!
        var destinationTime = 0.0
        var destinationStopId = ""
        var destinationLocation: CLLocationCoordinate2D!
        
        for timedLocation in schedule.timedLocations {
            if (timedLocation.seconds > curTimeInSecs) {
                destinationTime = timedLocation.seconds
                destinationStopId = timedLocation.stopId
                break
            }
            
            departingTime = timedLocation.seconds
            departingStopId = timedLocation.stopId
        }
        
        // If we've gotten to the end of the line, or haven't started yet, return nil
        if destinationStopId == "" || departingStopId == ""{
            return nil
        }
        
        if stops.northboundStops[departingStopId] != nil {
            departingLocation = stops.northboundStops[departingStopId]?.northboundLocation
            destinationLocation = stops.northboundStops[destinationStopId]?.northboundLocation
        } else {
            departingLocation = stops.southboundStops[departingStopId]?.southboundLocation
            destinationLocation = stops.southboundStops[destinationStopId]?.southboundLocation
        }
        
        // Determine the fraction between the two stops
        var duration = destinationTime - departingTime
        var fraction = (curTimeInSecs - departingTime) / duration
        
        
        // Linearly interpolate between the two stops
        var deltaLat = destinationLocation.latitude - departingLocation.latitude
        var deltaLon = destinationLocation.longitude - departingLocation.longitude
        
        var interpolatedLocation = CLLocationCoordinate2D(
            latitude: CLLocationDegrees(departingLocation.latitude + (fraction * deltaLat)),
            longitude: CLLocationDegrees(departingLocation.longitude + (fraction * deltaLon)))
        
        return interpolatedLocation
    }
    
    class func convertTimeToSeconds(time : String) -> Double {
        var components = time.componentsSeparatedByString(":")
        
        var hours = (components[0] as NSString).doubleValue
        var minutes = (components[1] as NSString).doubleValue
        var seconds = (components[2] as NSString).doubleValue
        
        return (hours * 60 * 60) + (minutes * 60) + seconds
    }
}