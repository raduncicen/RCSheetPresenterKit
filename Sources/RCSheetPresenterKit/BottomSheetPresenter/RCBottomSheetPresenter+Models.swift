//
//  RCBottomSheetPresenter+Models.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 20.02.2025.
//

import UIKit

extension Array<RCBottomSheetPresenter.Detent> {
    var hasSelfSizingDetent: Bool {
        contains { $0 == .selfSizing(fallback: .medium) } ||
        contains { $0 == .selfSizing(fallback: .large) }
    }
}

extension RCBottomSheetPresenter {
    /**
     Custom detent types for the bottom sheet.
     */
    public enum Detent: Equatable, Hashable {
        /// medium: Standard medium detent size provided by iOS.
        case medium

        /// Standard large detent size provided by iOS.
        case large

        /// custom(height: CGFloat, fallBack: Detent): Custom detent with a specified height. If iOS version is below 16, a fallback detent is used.
        case custom(height: CGFloat, fallBack: DetentFallBack)

        /// Requires your viewController to conform to `RCSelfSizingViewControllerProtocol` or use `RCSelfSizingHostingController` in for selfSizing to function properly. If iOS version is below 16, a fallback detent is used.
        case selfSizing(fallback: DetentFallBack)

        var detent: UISheetPresentationController.Detent? {
            switch self {
            case .medium:
                return .medium()
            case .large:
                return .large()
            case .custom(height: let height, fallBack: let fallBack):
                if #available(iOS 16.0, *) {
                    return .custom { _ in height }
                } else {
                    return fallBack.sheetDetent
                }
            case .selfSizing(fallback: let fallBack):
                if #available(iOS 16.0, *) {
                    return nil
                } else {
                    return fallBack.sheetDetent
                }
            }
        }

        public enum DetentFallBack: Equatable, Hashable {
            case medium
            case large

            var detent: Detent {
                switch self {
                case .medium:
                    return .medium
                case .large:
                    return .large
                }
            }

            var sheetDetent: UISheetPresentationController.Detent {
                switch self {
                case .medium:
                    return .medium()
                case .large:
                    return .large()
                }
            }
        }

    }
}

extension RCBottomSheetPresenter {

    /// Detents control how far the bottom sheet is presented. You can choose predefined detents like `.medium` and `.large` or create custom heights with `.custom(height:fallBack:)`. You can also prefer to use `.selfSizing(fallBack:)` which requires you to either implement `RCSelfSizingViewControllerProtocol` for your UIKit ViewController or use `RCSelfSizingHostingController` for SwiftUI views directly.
    ///
    /// If you're supporting iOS versions lower than iOS 16.0, custom detents will use the fallback values you define.
    ///
    /// `largestUndimmedDetent` is useful when you want to control the dimming behavior. For example, you can keep the bottom sheet content visible while preventing the background content from dimming.
    public struct DetentConfiguration {

        /// Allowed sheet sizes(detents) for the sheet.
        public var detents: [Detent]

        /// The largest detent level that doesn't dim the content behind the bottom sheet.
        public var largestUndimmedDetent: UndimmedDetentStyle = .none

        public enum UndimmedDetentStyle {
            /// Always dimmed
            case none
            /// Dims when sheet size grows larger than  the selfSized detent if there exists a larger detent.
            case selfSized
            /// Dims when sheet size grows larger than  the specified custom detent.
            /// - Note: `DetentConfiguration.detents` array should also include the same detent for this to work,
            case detent(Detent)
        }
    }

    public struct UIConfiguration {
        /// Determines whether the grab indicator is visible. Defaults to `true`.
        public var showsGrabIndicator: Bool = true
        /// Specifies whether the bottom sheet can be dismissed interactively by swiping down. Defaults to `true`.
        public var enableInteractiveDismiss: Bool = true
        /// The corner radius for the bottom sheet. Defaults to `32`.
        public var preferredCornerRadius: CGFloat = 32
    }
}
