//
//  TrackingState+Description.swift
//  AugmentedCamera
//
//  Created by 大山 貴史 on 2018/03/28.
//  Copyright © 2018年 Takafumi Oyama. All rights reserved.
//

import ARKit

extension ARCamera.TrackingState {
    public var description: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                return "TRACKING LIMITED\nToo much camera movement"
            case .insufficientFeatures:
                return "TRACKING LIMITED\nNot enough surface detail"
            case .initializing:
                return "Tracking LIMITED\nInitialization in progress."
            }
        }
    }
}

