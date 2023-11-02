//
//  LocationHelper.swift
//  Breathe
//
//  Created by Jacob Trentini on 7/26/23.
//

import Foundation
import CoreLocation
import MapKit
import Combine

extension MapViewController {
    public class LocationsHelper: NSObject, ObservableObject, CLLocationManagerDelegate {
        public static let shared = LocationsHelper()
        public var mapView: MKMapView
        let manager = CLLocationManager()
        
        @Published public var coordinate = CLLocationCoordinate2D()
        @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
        
        var cancellables = Set<AnyCancellable>()
        
        override private init() {
            self.mapView = MKMapView()
            
            super.init()
            
            manager.delegate = self
            manager.requestLocation()
            manager.startUpdatingLocation()
            manager.requestWhenInUseAuthorization()
        }
        
        public enum CenteringLocation {
            case user
            case custom(CLLocationCoordinate2D)
            
            var coordinate: CLLocationCoordinate2D {
                switch self {
                case .user:                 return LocationsHelper.shared.coordinate
                case .custom(let location): return location
                }
            }
        }
        
        public func center(on location: CenteringLocation,
                           latitudinalMeters:  CLLocationDistance = 1000,
                           longitudinalMeters: CLLocationDistance = 1000) {
            MapViewController.LocationsHelper.shared.mapView.setRegion(.init(center: location.coordinate,
                                                                             latitudinalMeters:  latitudinalMeters,
                                                                             longitudinalMeters: longitudinalMeters),
                                                                       animated: true)
        }
        
        public func centerMapOnNextUserLocationUpdate() {
            $coordinate
                .dropFirst()
                .sink { coordinate in
                    self.cancellables = []
                    self.center(on: .custom(coordinate))
                }
                .store(in: &cancellables)
        }
        
        public func invokeMapUpdate() {
            mapView.delegate?.mapView?(mapView, regionDidChangeAnimated: false)
        }
        
        // MARK: CLLocationManagerDelegate
        
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let userLocation = locations.first {
                coordinate = userLocation.coordinate
            }
        }
        
        public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            authorizationStatus = manager.authorizationStatus
        }
        
        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            dump(error)
        }
    }
}
