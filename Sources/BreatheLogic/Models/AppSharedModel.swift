//
//  AppSharedModel.swift
//  Breathe
//
//  Created by Jacob Trentini on 4/4/23.
//

import SwiftUI
import Combine
import GameplayKit
import BreatheShared
import BottomSheet
import UIKit

public enum AirQualityLayer: Int, CaseIterable {
    case wildfires
    case cities
    case both
    
    public var localizedDescription: String {
        switch self {
        case .wildfires: return "Wildfires"
        case .cities:    return "Cities"
        case .both:      return "Both"
        }
    }
    
    public var image: Image {
        switch self {
        case .wildfires: return Image(systemName: "flame")
        case .cities:    return Image(systemName: "building.2")
        case .both:      return Image(uiImage: UIImage(named: "FlameBuilding")!)
        }
    }
    
    public var isWildfire: Bool {
        self == .wildfires || self == .both
    }
    
    public var isCities: Bool {
        self == .cities || self == .both
    }
}

public class AppSharedModel: ObservableObject {
    @Published public var spatialSensors = GKRTree<PollenAnnotation>(maxNumberOfChildren: 2)
    @Published public var sensors: Set<Sensor> = []
    
    @Published public var tileOverlayRenderProgress = 0.0
    
    @Published public var spatialCities = GKRTree<CityAnnotation>(maxNumberOfChildren: 2)
    @Published public var cities: Set<City> = []
    
    @Published public var isCityLinkedSensorsSheetPresented = false
    @Published public var cityPresented: City?
    
    @AppStorage("isOnboardingSummaryPresented") public  var isOnboardingSummaryPresented = false
    
    @AppStorage("airQualityLayer")              public  var airQualityLayerInt    = AirQualityLayer.both       .rawValue
    @AppStorage("dataType")                     private var dataTypeInt           = DataType.individualSensor .rawValue
    @AppStorage("selectedDataLayer")            private var selectedDataLayerInt  = Layers.airQuality         .rawValue
    @AppStorage("mapType")                      private var mapTypeInt            = MapType.standard          .rawValue
    @AppStorage("temperatureType")              private var temperatureTypeInt    = TemperatureType.fahrenheit.rawValue
    
    @AppStorage("localityDictionary") private var cityDictionary = UserDefaults.standard.dictionary(forKey: "localityDictionary") as? [String: String] ?? [:]
    
    public init() { }
    
    public var dataType: Binding<DataType> {
        Binding(
            get: {
                DataType(rawValue: self.dataTypeInt) ?? .individualSensor
            },
            set: {
                self.dataTypeInt = $0.rawValue
            })
    }
    
    public var selectedDataLayer: Binding<Layers> {
        Binding(
            get: {
                return Layers(rawValue: self.selectedDataLayerInt)!
            },
            set: {
                self.selectedDataLayerInt = $0.rawValue
            })
    }
    
    public var mapType: Binding<MapType> {
        Binding(
            get: {
                MapType(rawValue: self.mapTypeInt) ?? .standard
            },
            set: {
                self.mapTypeInt = $0.rawValue
            })
    }
    
    public var temperatureType: Binding<TemperatureType> {
        Binding(
            get: {
                TemperatureType(rawValue: self.temperatureTypeInt) ?? .fahrenheit
            },
            set: {
                self.temperatureTypeInt = $0.rawValue
            })
    }
    
    public var airQualityLayer: Binding<AirQualityLayer> {
        Binding(
            get: {
                AirQualityLayer(rawValue: self.airQualityLayerInt) ?? .both
            },
            set: {
                self.airQualityLayerInt = $0.rawValue
            })
    }
}
