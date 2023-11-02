//
//  WildfireAnnotation.swift
//  Breathe
//
//  Created by Jacob Trentini on 9/9/23.
//

import MapKit
import BreatheShared

public class WildfireAnnotation: NSObject, MKAnnotation {
    public var title:       String?
    public var subtitle:    String?
    public var coordinate:  CLLocationCoordinate2D
    public var wildfire:    Wildfire
    
    public init(wildfire: Wildfire) {
        self.title      = wildfire.name
        self.subtitle   = wildfire.localizedDescription.isEmpty ? "No Description" : wildfire.localizedDescription
        self.coordinate = wildfire.coordinate.toCoreLocationCoordinate()
        self.wildfire   = wildfire
    }
}
