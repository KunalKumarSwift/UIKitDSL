// UIKitDSLLayout — EdgeInsets+DSL.swift
import UIKit

public extension UIEdgeInsets {
    static func all(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }
    static func horizontal(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }
    static func vertical(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: 0, bottom: value, right: 0)
    }
    static func symmetric(h: CGFloat, v: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: v, left: h, bottom: v, right: h)
    }
}
