//
//  MapRender.swift
//  Breathe
//
//  Created by Jacob Trentini on 1/21/23.
//

import Foundation
import GameplayKit
import MapKit

public class MapRender {
    public static func calculateRenderOperation<T: MKAnnotation>(spatialTree: GKRTree<T>,
                                                                 mapView: MKMapView,
                                                                 currentAnnotations: [MKAnnotation],
                                                                 maximumAnnotationsToDisplay: Int,
                                                                 render: @escaping (_ addAnnotations: [T],
                                                                                    _ removeAnnotations: [T],
                                                                                    _ updatedAnnotations: [T: T]) -> Void
    ) {
        DispatchQueue.global(qos: .background).async {
            var existingSensors = Set<T>()
            for annotation in currentAnnotations {
                if let sensor = annotation as? T {
                    existingSensors.insert(sensor)
                }
            }
            
            // TODO: This breaks around the international date line, but 🤷
            let minLatitude  = mapView.region.center.latitude  - mapView.region.span.latitudeDelta / 2
            let maxLatitude  = mapView.region.center.latitude  + mapView.region.span.latitudeDelta / 2
            let minLongitude = mapView.region.center.longitude - mapView.region.span.longitudeDelta / 2
            let maxLongitude = mapView.region.center.longitude + mapView.region.span.longitudeDelta / 2
            
            var visibleSensors = spatialTree.elements(inBoundingRectMin: vector_float2(Float(minLatitude), Float(minLongitude)), rectMax: vector_float2(Float(maxLatitude), Float(maxLongitude)))
            
            let drawSensors: ArraySlice<T>
            if visibleSensors.count > maximumAnnotationsToDisplay {
                // Choose a sample if we have too many sensors. Slightly prefer sensors already on the map if they are still in the target region to make panning more stable.
                var remainingSensors = Set<T>()
                
                for existing in existingSensors {
                    if existing.coordinate.latitude >= minLatitude && existing.coordinate.latitude <= maxLatitude && existing.coordinate.longitude >= minLongitude && existing.coordinate.longitude <= maxLongitude {
                        remainingSensors.insert(existing)
                    }
                }
                
                visibleSensors.shuffle()
                
                for sensor in visibleSensors[..<maximumAnnotationsToDisplay] {
                    remainingSensors.insert(sensor)
                }
                
                drawSensors = Array<T>(remainingSensors)[..<maximumAnnotationsToDisplay]
            } else {
                drawSensors = visibleSensors[..<visibleSensors.count]
            }
            
            var addSensors = Set<T>()
            var updatedAnnotations = [T: T]()
            
            for sensor in drawSensors {
                if existingSensors.contains(sensor) {
                    if let existing = existingSensors.remove(sensor) {
    //                    if existing.sensor.airQuality.aqi != existing.sensor.airQuality.aqi {
    //                        updatedAnnotations[existing] = sensor
    //                    }
                    }
                } else {
                    addSensors.insert(sensor)
                }
            }
            
            let addAnnotations = Array<T>(addSensors)
            let removeAnnotations = Array<T>(existingSensors)
            
            DispatchQueue.main.async {
                render(addAnnotations, removeAnnotations, updatedAnnotations)
            }
        }
    }

}
