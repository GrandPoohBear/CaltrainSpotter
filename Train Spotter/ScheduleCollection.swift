//
//  ScheduleCollection.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation

class ScheduleCollection : NSObject {
    var schedules = [ScheduleModel]()
    
    func parseFromFile() {
        let csvURL = NSBundle.mainBundle().URLForResource("stop_times", withExtension: "txt")
        var error: NSErrorPointer = nil
        let csv = CSV(contentsOfURL: csvURL!, error: error)
        
        let rows = csv?.rows
        
        var lastStopNum = 0
        var currentTrip = ScheduleModel()
        
        for rowDict in rows! {
            var tripId = rowDict["trip_id"]
            var arrivalTime = rowDict["arrival_time"]
            var departureTime = rowDict["departure_time"]
            var stopId = rowDict["stop_id"]
            var stopSequence = rowDict["stop_sequence"]
            var stopNum = (stopSequence! as NSString).integerValue
            
            if (stopNum < lastStopNum) {
                commitTrip(currentTrip)
                currentTrip = ScheduleModel()
            }
            
            lastStopNum = stopNum
            if (currentTrip.dayType == ScheduleModel.ScheduleType.UNSET) {
                currentTrip.dayType = determineScheduleType(tripId!)
            }
            
            var arrivalSecs = ScheduleUtilities.convertTimeToSeconds(arrivalTime!)
            var departureSecs = ScheduleUtilities.convertTimeToSeconds(departureTime!)
            if ((departureSecs - arrivalSecs) > 30 ) {
                println("Departure and arrival times vary! A = \(arrivalTime) and D = \(departureTime)")
            }
            
            var timedLocation = ScheduleModel.TimedLocation()
            timedLocation.seconds = arrivalSecs
            timedLocation.stopId = stopId!
            
            currentTrip.timedLocations.append(timedLocation)
            
        }
    }
    
    func commitTrip(trip : ScheduleModel) {
        schedules.append(trip)
    }
    
    func determineScheduleType(tripId : NSString) -> ScheduleModel.ScheduleType {
        if (tripId.containsString("Saturday")) {
            return ScheduleModel.ScheduleType.SATURDAY
        } else if (tripId.containsString("Sunday")) {
            return ScheduleModel.ScheduleType.SUNDAY
        } else if (tripId.containsString("Weekday")) {
            return ScheduleModel.ScheduleType.WEEKDAY
        } else if (tripId.containsString("Mixed")) {
            return ScheduleModel.ScheduleType.MIXED
        } else {
            println("Couldn't find a keyword for a schedule type for \(tripId)")
            return ScheduleModel.ScheduleType.UNSET
        }
    }
}