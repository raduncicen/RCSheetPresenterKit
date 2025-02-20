//
//  RCSwiftUIViewSizeCalculator.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//
import SwiftUI

public class RCSwiftUIViewSizeCalculator {
    static public func calculateHeight<Content: View>(for view: Content, width: CGFloat) -> CGFloat {
        let hostingController = UIHostingController(rootView: view)

        // Apply width constraint
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = hostingController.view.widthAnchor.constraint(equalToConstant: width)
        widthConstraint.isActive = true

        // Force layout pass
        let targetSize = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)
        let calculatedSize = hostingController.view.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel)
        let height = calculatedSize.height

        widthConstraint.isActive = false // Cleanup constraint
        return height
    }
}
