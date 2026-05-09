// UIKitDSLComponents — ImageComponent.swift
import UIKit
import UIKitDSLCore

public struct ImageComponent: ViewComponent {
    public var image: UIImage?
    public var contentMode: UIView.ContentMode = .scaleAspectFit
    public var tintColor: UIColor? = nil

    public init(image: UIImage? = nil) {
        self.image = image
    }

    public var id: AnyHashable { ObjectIdentifier(ImageComponent.self) as AnyHashable }

    public func build() -> UIView {
        let imageView = UIImageView()
        configure(imageView)
        return imageView
    }

    public func update(_ view: UIView) {
        guard let imageView = view as? UIImageView else { return }
        configure(imageView)
    }

    private func configure(_ imageView: UIImageView) {
        imageView.image = image
        imageView.contentMode = contentMode
        if let tintColor { imageView.tintColor = tintColor }
    }

    // MARK: - Value-type chaining modifiers

    public func contentMode(_ mode: UIView.ContentMode) -> ImageComponent {
        var copy = self; copy.contentMode = mode; return copy
    }

    public func tintColor(_ color: UIColor) -> ImageComponent {
        var copy = self; copy.tintColor = color; return copy
    }
}

public extension ViewComponent where Self == ImageComponent {
    static func image(_ image: UIImage? = nil) -> ImageComponent {
        ImageComponent(image: image)
    }

    static func image(systemName: String) -> ImageComponent {
        ImageComponent(image: UIImage(systemName: systemName))
    }
}
