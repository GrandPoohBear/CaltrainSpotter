//
//  ViewController.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    let routeCollection = RouteCollection()
    let stopCollection = StopCollection()
    let scheduleCollection = ScheduleCollection()

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        routeCollection.parseFromFile()
        stopCollection.parseFromFile()
        scheduleCollection.parseFromFile()
        
        mapView.setRegion(routeCollection.getCoordinateRegion(), animated: true)
        
        // Add polylines for the routes
        for (name, routeModel) in routeCollection.routes {
            var polyLine = routeModel.toPolyLine()
            println(polyLine.points())
            mapView.addOverlay(polyLine)
            
        }
        
        // Add points for the stops
        for (id, stopModel) in stopCollection.stops {
            mapView.addAnnotation(stopModel.toAnnotation())
        }
        
        // Determine current time and add trains
        let currentDateTime = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let curTime = timeFormatter.stringFromDate(currentDateTime)
        let curTimeSecs = ScheduleUtilities.convertTimeToSeconds(curTime)
        
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar!.components(.WeekdayCalendarUnit, fromDate: currentDateTime)
        let weekDay = myComponents.weekday
        
        
        for schedule in scheduleCollection.schedules {
            var trainLocation = ScheduleUtilities.determinePosition(schedule, weekDay: weekDay, curTimeInSecs: curTimeSecs, stops: stopCollection)
            if trainLocation != nil {
                var circle = MKCircle(centerCoordinate: trainLocation!, radius: CLLocationDistance(100))
                mapView.addOverlay(circle, level: MKOverlayLevel.AboveLabels)
            }
        }

    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay is MKPolyline) {
            var polyLineRenderer = MKPolylineRenderer(polyline: overlay as MKPolyline)
            polyLineRenderer.strokeColor = UIColor.greenColor()
            polyLineRenderer.lineWidth = 5.0
            return polyLineRenderer
        } else if (overlay is MKCircle) {
            var circleRenderer = MKCircleRenderer(circle: overlay as MKCircle)
            circleRenderer.fillColor = UIColor.blueColor()
            circleRenderer.strokeColor = UIColor.blackColor()
            return circleRenderer
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

