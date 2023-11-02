//
//  DataLayer.swift
//  Breathe
//
//  Created by Jacob Trentini on 5/13/23.
//

import SwiftUI

public enum DataLayer: Int, CaseIterable {
    case aqi
    case temperature
    case humidity
    
    public var localizedDescription: String {
        switch self {
        case .aqi:         return "AQI"
        case .temperature: return "Temperature"
        case .humidity:    return "Humidity"
        }
    }
    
    public var icon: Image {
        switch self {
        case .aqi:         return Image(systemName: "aqi.medium")
        case .temperature: return Image(systemName: "thermometer")
        case .humidity:    return Image(systemName: "humidity")
        }
    }
}
