//
//  Split.swift
//  StravaSwift
//
//  Created by Matthew on 24/11/2015.
//  Copyright © 2015 Matthew Clarkson. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Split {
    public var distance: Double?
    public var elapsedTime: Int?
    public var movingTime: Int?
    public var elevationDifference: Int?
    public var split: Int?
    
    public init(_ json: JSON) {
        distance = json["distance"].double
        elapsedTime = json["elapsed_time"].int
        movingTime = json["moving_time"].int
        elevationDifference = json["elevation_difference"].int
        split = json["split"].int
    }

}