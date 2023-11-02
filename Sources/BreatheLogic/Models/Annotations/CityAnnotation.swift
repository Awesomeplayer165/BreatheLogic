//
//  CityAnnotation.swift
//  Breathe
//
//  Created by Jacob Trentini on 7/18/23.
//

import MapKit
import BreatheShared

public class CityAnnotation: NSObject, MKAnnotation {
    public var title:       String?
    public var coordinate:  CLLocationCoordinate2D
    public var city:        City
    
    public init(city: City) {
        self.title      = city.reverseGeoCodedData.name
        self.coordinate = city.reverseGeoCodedData.coordinate.toCoreLocationCoordinate()
        self.city       = city
    }
}
