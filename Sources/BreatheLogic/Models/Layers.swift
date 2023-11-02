//
//  Layers.swift
//  BreatheRewrite
//
//  Created by Admin on 10/14/23.
//

import Foundation
import SwiftUI
import MapKit

public enum Layers: CaseIterable, LayerInterface {
    case airQuality
//    case wildfires
    case pollen
    
    public static var allCases: [Layers] = [.airQuality,
//                                            .wildfires,
                                            .pollen]
    
    public init?(rawValue: Int) {
        self = Layers.allCases[rawValue]
    }
    
    public var rawValue: Int {
        Layers.allCases.firstIndex { $0.localizedDescription == self.localizedDescription }!
    }
    
    public var localizedDescription: String {
        switch self {
        case .airQuality: return "Air Quality"
//        case .wildfires:  return "Wildfires"
        case .pollen:     return "Pollen"
        }
    }
    
    public var image: Image {
        switch self {
        case .airQuality: return Image(systemName: "aqi.medium")
//        case .wildfires:  return Image(systemName: "flame")
        case .pollen:     return Image(systemName: "sparkles")
        }
    }
    
    public var annotationsPersistBetweenMapUpdates: Bool {
        switch self {
        case .airQuality, .pollen: return false
//        case .wildfires:           return true
        }
    }
    
    public var associatedMKAnnotation: MKAnnotation.Type {
        switch self {
        case .airQuality: return SensorAnnotation  .self
//        case .wildfires:  return WildfireAnnotation.self
        case .pollen:     return PollenAnnotation  .self
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

public protocol LayerInterface: CaseIterable, Hashable {
    var localizedDescription:   String            { get }
    var image:                  Image             { get }
    var rawValue:               Int               { get }
    var associatedMKAnnotation: MKAnnotation.Type { get }
}
