// UIKitDSLAnimation — DSLAnimation.swift
// Placeholder; full implementation in progress.
import UIKit

public struct DSLAnimation {
    public enum Curve {
        case linear, easeIn, easeOut, easeInOut
        case spring(damping: CGFloat, response: TimeInterval)
        case custom(UICubicTimingParameters)
    }
    public let duration: TimeInterval
    public let curve: Curve
    public let delay: TimeInterval

    public init(duration: TimeInterval, curve: Curve, delay: TimeInterval = 0) {
        self.duration = duration; self.curve = curve; self.delay = delay
    }

    public static let smooth = DSLAnimation(duration: 0.35, curve: .easeInOut)
    public static let snappy = DSLAnimation(duration: 0.2, curve: .easeOut)
    public static let bouncy = DSLAnimation(duration: 0.5, curve: .spring(damping: 0.6, response: 0.4))
    public static func spring(damping: CGFloat = 0.7, response: TimeInterval = 0.4) -> DSLAnimation {
        DSLAnimation(duration: response, curve: .spring(damping: damping, response: response))
    }
}
