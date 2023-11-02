//
//  SelectedPanelType.swift
//  Breathe
//
//  Created by Jacob Trentini on 4/13/23.
//

import BreatheShared

public enum SelectedPanelType {
    case sensor(Sensor)
    case city(City)
    
    public var name: String? {
        switch self {
        case .sensor(let sensor): return sensor.name
        case .city(let city):     return city.reverseGeoCodedData.name
        }
    }
}

extension SelectedPanelType: Equatable {
    public static func == (lhs: SelectedPanelType, rhs: SelectedPanelType) -> Bool {
        lhs.name == rhs.name
    }
}
