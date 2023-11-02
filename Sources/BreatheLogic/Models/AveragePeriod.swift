//
//  AveragePeriod.swift
//
//
//  Created by Admin on 10/13/23.
//

import SwiftUI

public enum AveragePeriod: CaseIterable, Hashable {
    public static var allCases: [AveragePeriod] = [
        .minute10,
        .minute30,
        .hour1,
        .hour3,
        .hour6,
        .day,
        .custom(Date.now.addingTimeInterval(-3_600)...Date.now.addingTimeInterval(3_600))
    ]
    
    public static func getAveragePeriod(from sensorAveragesIndex: Int) -> AveragePeriod? {
        switch sensorAveragesIndex {
        case 1: return AveragePeriod.day
        case 2: return AveragePeriod.hour6
        case 3: return AveragePeriod.hour1
        case 4: return AveragePeriod.minute30
        case 5: return AveragePeriod.minute10
        default: return nil
        }
    }
    
    case minute10
    case minute30
    case hour1
    case hour3
    case hour6
    case day
    case custom(ClosedRange<Date>)
    
    public var localizedDescription: String {
        switch self {
        case .minute10: return "10 Minutes"
        case .minute30: return "30 Minutes"
        case .hour1:    return "1 Hour"
        case .hour3:    return "3 Hours"
        case .hour6:    return "6 Hours"
        case .day:      return "1 Day"
        case .custom:   return "Custom"
        }
    }
    
    public var icon: Image {
        switch self {
        case .minute10: return Image(systemName: "gobackward.10")
        case .minute30: return Image(systemName: "gobackward.30")
        case .hour1:    return Image(systemName: "1.circle")
        case .hour3:    return Image(systemName: "3.circle")
        case .hour6:    return Image(systemName: "6.circle")
        case .day:      return Image(systemName: "gobackward")
        case .custom:   return Image(systemName: "slider.horizontal.2.gobackward")
        }
    }
    
    public var period: ClosedRange<Date> {
//        let currentDate = Date.now
        let currentDate = Date(timeIntervalSince1970: 1684123323.0)
        
        switch self {
        case .minute10:          return currentDate.addingTimeInterval(-600)...currentDate
        case .minute30:          return currentDate.addingTimeInterval(-1_800)...currentDate
        case .hour1:             return currentDate.addingTimeInterval(-3_600)...currentDate
        case .hour3:             return currentDate.addingTimeInterval(-10_800)...currentDate
        case .hour6:             return currentDate.addingTimeInterval(-21_600)...currentDate
        case .day:               return currentDate.addingTimeInterval(-86_400)...currentDate
        case .custom(let range): return range
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(localizedDescription)
    }
}
