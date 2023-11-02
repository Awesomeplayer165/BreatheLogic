//
//  PurpleAirAPIErrors.swift
//  Breathe
//
//  Created by Jacob Trentini on 5/13/23.
//

import Alamofire

public enum PurpleAirAPIErrors: Error {
    case alamofireError(AFError)
    case failedDecoding
}
