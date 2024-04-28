//
//  File.swift
//  CWC_AR
//
//  Created by Hansen Yudistira on 24/04/24.
//

import SwiftUI
import ARKit

enum SpeechAction {
    case none, remove, plane, drummer, start, ridikulus, leviosa
}

enum Direction {
    case forward, backward, left, right, up, down, stay
    
    var symbol: String {
        switch self {
        case .forward:
            return "arrow.uturn.up"
        case .backward:
            return "arrow.uturn.down"
        case .left:
            return "arrow.left.circle.fill"
        case .right:
            return "arrow.right.circle.fill"
        case .up:
            return "arrow.up.circle.fill"
        case .down:
            return "arrow.down.circle.fill"
        case .stay:
            return "stay"
        }
    }
    
//    var vector : SIMD3<Float> {
//        switch self {
//        case .forward:
//            return SIMD3<Float>(0, 0, -0.1)
//        case .backward:
//            return SIMD3<Float>(0, 0, 0.1)
//        case .left:
//            return SIMD3<Float>(-0.1, 0, 0)
//        case .right:
//            return SIMD3<Float>(0.1, 0, 0)
//        case .up:
//            return SIMD3<Float>(0, 0.1, 0)
//        case .down:
//            return SIMD3<Float>(0, -0.1, 0)
//        }
//    }
}

enum ARAction {
    case placeBlock(color: Color)
    case removeAllAnchors
    case placeItem(item: String)
    case moveItem(direction: Direction) 
    case startApplyingForce(direction: Direction)
    case stopApplyingForce
    case translateItem(translation: CGSize)
    case pinchItem(magnitude: CGFloat)
}
