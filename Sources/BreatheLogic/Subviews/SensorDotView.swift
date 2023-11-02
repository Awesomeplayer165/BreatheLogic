//
//  SensorDotView.swift
//  Breathe
//
//  Created by Jacob Trentini on 10/27/22.
//

import SwiftUI
import BreatheShared

public struct SensorDotView: View {
    public let airQuality:               AirQuality
    public let radius:                   CGFloat
    public let textSize:                 CGFloat
    public let isShowingTextSize:        Bool
    public let isAdaptiveColorOverriden: Bool
    
    public init(airQuality:             AirQuality,
         radius:                 CGFloat = 40,
         textSize:               CGFloat = 14,
         isShowingTextSize:      Bool    = true,
         overridesAdaptiveColor: Bool    = false
    ) {
        self.airQuality               = airQuality
        self.radius                   = radius
        self.textSize                 = textSize
        self.isShowingTextSize        = isShowingTextSize
        self.isAdaptiveColorOverriden = overridesAdaptiveColor
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .foregroundColor(Color(!isAdaptiveColorOverriden ? airQuality.airQualityCategory.airQualityColor.adaptiveColor : airQuality.airQualityCategory.airQualityColor.primaryColor))
                .frame(width: radius, height: radius)
            
            if isShowingTextSize {
                Text("\(airQuality.aqi)")
                    .font(.system(size: textSize))
                    .foregroundColor(.white)
            }
        }
    }
}

struct SensorDotView_Previews: PreviewProvider {
    static var previews: some View {
        SensorDotView(airQuality: AirQuality(aqi: 401), radius: 50, overridesAdaptiveColor: true)
    }
}
