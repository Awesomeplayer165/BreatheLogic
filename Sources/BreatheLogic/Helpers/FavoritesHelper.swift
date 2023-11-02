//
//  FavoritesHelper.swift
//  Breathe
//
//  Created by Jacob Trentini on 9/13/23.
//

import Foundation
import SwiftUI
import BreatheShared
import Combine

public class FavoritesHelper: ObservableObject {
    public var sensors: Set<Sensor> = []
    public var cities:  Set<City>   = []
    
    public init() { }
    
    @AppStorage("favoriteSensors") public private(set) var favoriteSensorIds: [Int] = [] {
        didSet {
            loadSensors()
            objectWillChange.send()
        }
    }
    
    @AppStorage("favoriteCities") public private(set) var favoriteCityIds: [String] = [] {
        didSet {
            loadCities()
            objectWillChange.send()
        }
    }
    
    @Published public var favoriteSensors: Set<Sensor> = []
    @Published public var favoriteCities:  Set<City>   = []
    
    public func loadSensors() {
        favoriteSensors = []
        
        favoriteSensors = Set(favoriteSensorIds.compactMap { favoriteSensorId in
            sensors.first { $0.id == favoriteSensorId }
        })
        
        print("Favorites Helper Loaded Sensors")
    }
    
    public func loadCities() {
        favoriteCities = []
        
        favoriteCities = Set(favoriteCityIds.compactMap { favoriteCityId in
            cities.first { $0.reverseGeoCodedData.name == favoriteCityId }
        })
        
        print("Favorites Helper Loaded Cities")
    }
    
    @discardableResult
    public func add(sensor: Sensor) -> Sensor {
        favoriteSensorIds.append(sensor.id)
        return sensor
    }
    
    @discardableResult
    public func add(city: City) -> City {
        favoriteCityIds.append(city.reverseGeoCodedData.placeId)
        return city
    }
    
    @discardableResult
    public func remove(sensor: Sensor) -> Sensor {
        favoriteSensorIds.removeAll { sensor.id == $0 }
        return sensor
    }
    
    @discardableResult
    public func remove(city: City) -> City {
        favoriteCityIds.removeAll { city.reverseGeoCodedData.placeId == $0 }
        return city
    }
}

enum FavoritesHelperErrors: Error {
    case duplicateSensor
}
