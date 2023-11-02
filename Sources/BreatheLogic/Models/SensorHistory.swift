//
//  SensorHistory.swift
//  Breathe
//
//  Created by Jacob Trentini on 5/2/23.
//

import Foundation
import BreatheShared

public struct SensorHistory {
    public let average: AirQuality
    public let history: [SensorHistoryAirQualityValues]
    public var animate = false
}

public struct SensorHistoryAirQualityValues {
    public let timestamp: Date
    public let channelA: AirQuality
    public let channelB: AirQuality
}
