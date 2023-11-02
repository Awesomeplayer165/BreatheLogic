//
//  SettingTypes.swift
//
//
//  Created by Admin on 10/13/23.
//

import MapKit

public enum DataType: Int {
    case individualSensor
    case groupByCity
    
    public var localizedDescription: String {
        switch self {
        case .individualSensor: return "Sensors"
        case .groupByCity:      return "Group By City"
        }
    }
}

public enum MapType: Int {
    case standard
    case satellite
    
    public var localizedDescription: String {
        switch self {
        case .standard:  return "Standard"
        case .satellite: return "Satellite"
        }
    }
    
    public var mapKitType: MKMapType { MKMapType(rawValue: UInt(rawValue)) ?? .standard }
}
