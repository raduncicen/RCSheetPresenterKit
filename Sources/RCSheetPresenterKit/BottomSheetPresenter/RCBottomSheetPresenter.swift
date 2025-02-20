//
//  RCBottomSheetPresenter.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import SwiftUI

@available(iOS 15.0, *)
class RCBottomSheetPresenter {
    private let navigationController: UINavigationController

    /// - Parameter navigationController: The navigationController in which the bottomSheet will be presented on.
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    // MARK: - Public Methods

    func presentBottomSheet<Content: View>(
        view: Content,
        configuration: Configuration,
        animateChangesOnDetentChange: ((_ selectedDetent: UISheetPresentationController.Detent.Identifier?) -> ())? = nil,
        completion: (() -> Void)? = nil
    ) {
        let viewController: UIViewController
        
        if configuration.useSelfSizing {
            viewController = RCSelfSizingHostingController(rootView: view)
        } else {
            viewController = UIHostingController(rootView: view)
        }

        presentBottomSheet(
            viewController: viewController,
            configuration: configuration,
            animateChangesOnDetentChange: animateChangesOnDetentChange,
            completion: completion
        )
    }



    /// Presents a view controller as a bottom sheet with configurable options.
    /// - Parameters:
    ///   - viewController: The view controller to present as a bottom sheet.
    ///   - configuration: <#configuration description#>
    ///   - animateChangesOnDetentChange: A closure that triggers when the selected detent changes. The closure provides the identifier of the selected detent. You can use this to make some animations inside you view like animating and using  different ///navigation titles on different detent sizes.
    ///   - completion: A closure to be executed after the bottom sheet presentation finishes.
    ///
    /// - Note:
    /// - If `animateChangesOnDetentChange` is provided, this closure will be executed whenever the user changes the detent (height) of the bottom sheet.
    func presentBottomSheet(
        viewController: UIViewController,
        configuration: Configuration,
        animateChangesOnDetentChange: ((_ selectedDetent: UISheetPresentationController.Detent.Identifier?) -> ())? = nil,
        completion: (() -> Void)? = nil
    ) {
        // Set the presentation style for the bottom sheet
        viewController.modalPresentationStyle = .pageSheet
        viewController.isModalInPresentation = !configuration.enableInteractiveDismiss

        // Set up the bottom sheet's presentation controller
        guard let sheetController = viewController.sheetPresentationController else {
            assertionFailure("Make sure that the modalPresentationStyle is set to .pageSheet")
            navigationController.present(viewController, animated: true, completion: completion)
            return
        }

        sheetController.prefersGrabberVisible = configuration.showsGrabIndicator
        sheetController.preferredCornerRadius = configuration.preferredCornerRadius
        var configurationDetents = Array(Set(configuration.detents))

        if #available(iOS 16.0, *) {
            if configuration.useSelfSizing {
                // Calculate the preferred content size of the view controller
                let contentHeight = viewController.preferredContentSize.height
                configurationDetents.insert(.custom(height: contentHeight, fallBack: .large), at: 0)
            }
        }

        /// - WARNING: Make sure to always set the final detent values before querying for largestUndimmedDetent. This is need for detent identifiers to sustain and match.
        sheetController.detents = configurationDetents.map(\.detent)

        // Set the largest undimmed detent if iOS 16+ is available
        if #available(iOS 16.0, *) {
            if let largestUndimmedDetent = configuration.largestUndimmedDetent,
               let detentIndex = configurationDetents.firstIndex(of: largestUndimmedDetent) {
                sheetController.largestUndimmedDetentIdentifier = sheetController.detents[detentIndex].identifier
            }
        }

        // Handle detent change animation
        sheetController.animateChanges {
            animateChangesOnDetentChange?(sheetController.selectedDetentIdentifier)
        }

        // Present the view controller on the navigation controller
        navigationController.present(viewController, animated: true, completion: completion)
    }
}

@available(iOS 15.0, *)
extension RCBottomSheetPresenter {
    /**
     Custom detent types for the bottom sheet.

     - medium: Standard medium detent size provided by iOS.
     - large: Standard large detent size provided by iOS.
     - custom(height: CGFloat, fallBack: Detent): Custom detent with a specified height. If iOS version is below 16, a fallback detent is used.
     */
    indirect enum Detent: Equatable, Hashable {
        case medium
        case large
        case custom(height: CGFloat, fallBack: Detent)

        var detent: UISheetPresentationController.Detent {
            switch self {
            case .medium:
                return .medium()
            case .large:
                return .large()
            case .custom(height: let height, fallBack: let fallBack):
                if #available(iOS 16.0, *) {
                    return .custom { _ in height }
                } else {
                    return fallBack.detent
                }
            }
        }
    }
}

@available(iOS 15.0, *)
extension RCBottomSheetPresenter {
    /*
     Detents control how far the bottom sheet is presented. You can choose predefined detents like `.medium` and `.large` or create custom heights with `.custom(height:fallBack:)`.

     If you're supporting iOS versions lower than iOS 16.0, custom detents will fallback to predefined detents.

     `largestUndimmedDetent` is useful when you want to control the dimming behavior. For example, you can keep the bottom sheet content visible while preventing the background content from dimming.
     **/
    struct Configuration {
        /// A list of detents (i.e., heights) for the bottom sheet. Defaults to `[.medium]`. You can define custom heights using `.custom(height: CGFloat, fallBack: Detent)`
        var detents: [Detent] = [.medium]
        /// The largest detent level that doesn't dim the content behind the bottom sheet.
        var largestUndimmedDetent: Detent?
        /// Sets a custom indent for the swiftUIView defined. This will only work if the view is embedded inside `RCSelfSizingHostingController`, when `iOS 16+` and the view has a `frame(minHeight: )` set
        var useSelfSizing: Bool = false
        /// A Boolean value that determines whether the grab indicator is visible. Defaults to `true`.
        var showsGrabIndicator: Bool = true
        /// A Boolean value that specifies whether the bottom sheet can be dismissed interactively by swiping down. Defaults to `true`.
        var enableInteractiveDismiss: Bool = true
        /// The corner radius for the bottom sheet. Defaults to `32`.
        var preferredCornerRadius: CGFloat = 32
    }
}

@available(iOS 15.0, *)
extension RCBottomSheetPresenter.Configuration {
    static var defaultMedium: Self {
        .init(
            detents: [.medium],
            useSelfSizing: false,
            showsGrabIndicator: true,
            enableInteractiveDismiss: true,
            preferredCornerRadius: 32
        )
    }

    static var defaultLarge: Self {
        .init(
            detents: [.large],
            useSelfSizing: false,
            showsGrabIndicator: true,
            enableInteractiveDismiss: true,
            preferredCornerRadius: 32
        )
    }

    static var selfSizing: Self {
        .init(
            detents: [.medium],
            useSelfSizing: true,
            showsGrabIndicator: true,
            enableInteractiveDismiss: true,
            preferredCornerRadius: 32
        )
    }

    static var mediumLarge: Self {
        .init(
            detents: [.medium, .large],
            useSelfSizing: false,
            showsGrabIndicator: true,
            enableInteractiveDismiss: true,
            preferredCornerRadius: 32
        )
    }
}


// MARK: - Preview

//#Preview {
//    RCPreviewer(
//        { navigationController in
//            let view = Color.red.navigationBarHidden(true).ignoresSafeArea()
//            let rootVC = UIHostingController(rootView: view)
//            navigationController.pushViewController(rootVC, animated: true)
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                let view = Color.green.ignoresSafeArea()
//
//                let viewController = UIHostingController(rootView: view)
//
//                RCBottomSheetPresenter(navigationController: navigationController)
//                    .presentBottomSheet(
//                        viewController: viewController,
//                        configuration: .init(
//                            detents: [
//                                .custom(height: 100, fallBack: .medium),
//                                .custom(height: 250, fallBack: .medium),
//                                .medium,
//                                .large
//                            ],
//                            largestUndimmedDetent: .custom(height: 100, fallBack: .medium),
//                            useSelfSizing: false,
//                            showsGrabIndicator: true,
//                            enableInteractiveDismiss: true,
//                            preferredCornerRadius: 30
//                        )
//                    )
//            }
//
//            return rootVC
//        })
//}
