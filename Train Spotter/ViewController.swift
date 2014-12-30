//
//  ViewController.swift
//  Train Spotter
//
//  Created by Andy Isaacson on 12/27/14.
//  Copyright (c) 2014 Tutukain. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    let routeCollection = RouteCollection()
    let stopCollection = StopCollection()
    let scheduleCollection = ScheduleCollection()
    
    var trains = [MKCircle]()
    var trainUpdateTimer: NSTimer!
    
    let ViewSpanInMiles = 5.0
    let MilesToDegrees = (1.0 / 69.0)
    
    var userMovedMap = false
    
    var locationManager:CLLocationManager!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // Initialize our data from files
            // TODO: Move to a background thread
            self.routeCollection.parseFromFile()
            self.stopCollection.parseFromFile()
            self.scheduleCollection.parseFromFile()
            
            dispatch_async(dispatch_get_main_queue()) {
                // Move the map view to the region around the Caltrain line
                self.mapView.setRegion(self.routeCollection.getCoordinateRegion(), animated: true)
                
                // We won't want to keep updating the map region if the user moves it themselves
                // add a gesture recognizer to the map to prevent future updates
                var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "didDragMap:")
                panGestureRecognizer.delegate = self
                self.mapView.addGestureRecognizer(panGestureRecognizer)
                
                // Set things up to get the user's location
                self.locationManager = CLLocationManager()
                self.locationManager.delegate = self
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                self.locationManager.requestWhenInUseAuthorization()
                self.locationManager.startUpdatingLocation()
                
                self.addRouteOverlays()
                self.addStopAnnotations()
                
                self.updateTrains()
                
                self.trainUpdateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "updateTrains", userInfo: nil, repeats: true)            }
        }
        
        
        
    }
    
    func addRouteOverlays() {
        // Add polylines for the routes
        for (name, routeModel) in routeCollection.routes {
            var polyLine = routeModel.toPolyLine()
            mapView.addOverlay(polyLine)
            
        }
    }
    
    func addStopAnnotations() {
        // Add points for the stops
        for (id, stopModel) in stopCollection.stops {
            mapView.addAnnotation(stopModel.toAnnotation())
        }
    }
    
    func updateTrains() {
        // Remove any old circles
        // TODO: Update these instead of always removing/adding
        mapView.removeOverlays(trains)
        trains.removeAll(keepCapacity: true)
        
        // Determine current time and day of week
        let currentDateTime = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        let curTime = timeFormatter.stringFromDate(currentDateTime)
        let curTimeSecs = ScheduleUtilities.convertTimeToSeconds(curTime)
        
        let myCalendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)
        let myComponents = myCalendar!.components(.WeekdayCalendarUnit, fromDate: currentDateTime)
        let weekDay = myComponents.weekday
        
        // Add the train locations
        for schedule in scheduleCollection.schedules {
            var trainLocation = ScheduleUtilities.determinePosition(schedule, weekDay: weekDay, curTimeInSecs: curTimeSecs, stops: stopCollection)
            if trainLocation != nil {
                var circle = MKCircle(centerCoordinate: trainLocation!, radius: CLLocationDistance(200))
                trains.append(circle)
                
            }
        }
        
        mapView.addOverlays(trains, level: MKOverlayLevel.AboveLabels)

    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay is MKPolyline) {
            
            // So far we're only using poly lines for the train tracks
            var polyLineRenderer = MKPolylineRenderer(polyline: overlay as MKPolyline)
            polyLineRenderer.strokeColor = UIColor.greenColor()
            polyLineRenderer.lineWidth = 5.0
            return polyLineRenderer
            
        } else if (overlay is MKCircle) {
            
            // The MKCircles are trains - this may change
            var circleRenderer = MKCircleRenderer(circle: overlay as MKCircle)
            circleRenderer.fillColor = UIColor.blueColor()
            circleRenderer.strokeColor = UIColor.blackColor()
            circleRenderer.lineWidth = 2.0
            return circleRenderer
            
        }
        return nil
    }
    
    // Callback for location updates
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        // If the user moves the map manually, don't keep updating it underneath them.
        if (userMovedMap) {
            return
        }
        
        var routeRegion = routeCollection.getCoordinateRegion()
        
        var location = locations[0] as CLLocation
        var coord = location.coordinate
        
        if GeoUtilities.isCoordinateWithinRegion(coord, region: routeRegion, mapView: mapView!) {
            let tightSpan = MKCoordinateSpanMake(ViewSpanInMiles * MilesToDegrees, ViewSpanInMiles * MilesToDegrees)
            let tightRegion = MKCoordinateRegionMake(coord, tightSpan)
            mapView.setRegion(tightRegion, animated: true)
        }
    }
    
    // Gesture recognizer to detect map moving
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func didDragMap(gestureRecognizer: UIGestureRecognizer) {
        
        if (gestureRecognizer.state == UIGestureRecognizerState.Began) {
            userMovedMap = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

