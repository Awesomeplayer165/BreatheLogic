//
//  SensorAnnotation.swift
//  Breathe
//
//  Created by Jacob Trentini on 7/18/23.
//

import MapKit
import BreatheShared
import SwiftUI

public class SensorAnnotation: NSObject, MKAnnotation {
    public var title:                                    String?
    public var coordinate:                               CLLocationCoordinate2D
    public var sensor:                                   Sensor
    public var participatesInSpatialAnnotationRendering: Bool
    
    public init(sensor: Sensor,
                participatesInSpatialAnnotationRendering: Bool = true
    ) {
        self.title                                    = sensor.name
        self.coordinate                               = sensor.coordinate.toCoreLocationCoordinate()
        self.sensor                                   = sensor
        self.participatesInSpatialAnnotationRendering = participatesInSpatialAnnotationRendering
    }
}
