//
//  TemperatureType.swift
//  Breathe
//
//  Created by Jacob Trentini on 5/13/23.
//

import Foundation

public enum TemperatureType: Int, CaseIterable {
    case fahrenheit
    case celsius
    case kelvin
    
    public var localizedDescription: String {
        switch self {
        case .fahrenheit: return "Fahrenheit"
        case .celsius:    return "Celsius"
        case .kelvin:     return "Kelvin"
        }
    }
    
    public  var shortLocalizedDescription: String {
        "°\(localizedDescription.first!)"
    }
    
    public func toUnitTemperature() -> UnitTemperature {
        switch self {
        case .fahrenheit: return .fahrenheit
        case .celsius:    return .celsius
        case .kelvin:     return .kelvin
        }
    }
}
