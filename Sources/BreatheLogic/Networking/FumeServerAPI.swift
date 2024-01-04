//
//  BreatheServerAPI.swift
//  Breathe
//
//  Created by Jacob Trentini on 7/19/23.
//

import Foundation
import BreatheShared
import CoreLocation

public enum BreatheServerErrors: Error {
    case urlInvalid
}

public class BreatheServerAPI {
    public static let shared = BreatheServerAPI()
    private init() {}
    
    private class Endpoints {
        private static let hostName = "https://fumeaqi.jacob2.dev"
        
        public static func autocomplete(for query: String) -> String {
            "\(hostName)/autocomplete/\(query)"
        }
        
        public static func cities(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, excludedCities: [String]) -> String {
            "\(hostName)/cities/\(topLeft.latitude)/\(topLeft.longitude)/\(bottomRight.latitude)/\(bottomRight.longitude)/\(excludedCities)"
        }
        
        public static func wildfires() -> String {
            "\(hostName)/wildfires"
        }
        
        public static func airNowStations() -> String {
            "\(hostName)/airNowStations"
        }
    }
    
    public func autocomplete(for query: String) async throws -> [City] {
        guard let url = Endpoints.autocomplete(for: query).asURL() else { throw BreatheServerErrors.urlInvalid }
        return try await fetchDataAndDecodeJson(url: url, type: [City]().self)
    }
    
    public func cities(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D, excludedCities: [String]) async throws -> Set<City> {
        guard let url = Endpoints.cities(topLeft: topLeft, bottomRight: bottomRight, excludedCities: excludedCities).asURL() else { throw BreatheServerErrors.urlInvalid }
        return Set(try await fetchDataAndDecodeJson(url: url, type: [City]().self))
    }
    
    public func wildfires() async throws -> Set<Wildfire> {
        guard let url = Endpoints.wildfires().asURL() else { throw BreatheServerErrors.urlInvalid }
        return Set(try await fetchDataAndDecodeJson(url: url, type: [Wildfire]().self))
    }
    
    public func airNowStations() async throws -> Set<AirNowStation> {
        guard let url = Endpoints.airNowStations().asURL() else { throw BreatheServerErrors.urlInvalid }
        let json = try await fetchDataAndDecodeJson(url: url, type: [AirNowStation]().self)
        return Set(json)
    }
    
    private func fetchDataAndDecodeJson<T: Codable>(url: URL, type: T) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
