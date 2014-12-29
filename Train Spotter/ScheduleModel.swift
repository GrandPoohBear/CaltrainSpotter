//
//  ScheduleModel.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import Foundation
import MapKit

class ScheduleModel : NSObject {
    class TimedLocation : NSObject {
        var seconds : Double = 0.0
        var stopId : String = ""
    }
    
    enum ScheduleType {
        case UNSET, WEEKDAY, MIXED, SATURDAY, SUNDAY
    }
    
    var timedLocations = [TimedLocation]()
    var dayType : ScheduleType = ScheduleType.UNSET
}