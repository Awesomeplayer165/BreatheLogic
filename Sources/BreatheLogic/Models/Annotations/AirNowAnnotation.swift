//
//  AirNowAnnotation.swift
//  Breathe
//
//  Created by Jacob Trentini on 9/15/23.
//

import MapKit
import BreatheShared

public class AirNowAnnotation: NSObject, MKAnnotation {
    public var title:       String?
    public var subtitle:    String?
    public var coordinate:  CLLocationCoordinate2D
    public var station:     AirNowStation
    
    public init(station: AirNowStation) {
        self.title      = station.name
        self.subtitle   = Date.RelativeFormatStyle().format(station.lastUpdated)
        self.coordinate = station.coordinate.toCoreLocationCoordinate()
        self.station    = station
    }
}
