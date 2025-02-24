//
//  RCBottomSheetPresenter.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import SwiftUI

public class RCBottomSheetPresenter {
    let navigationController: UINavigationController

    static var ios16Plus: Bool = {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }()

    /// - Parameter navigationController: The navigationController in which the bottomSheet will be presented on.
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension RCBottomSheetPresenter {

    /// Presents a sheet over the given navigationController
    /// - Parameters:
    ///   - view: SwiftUI view which you want to present. Self-sizing detent is automatically supported if enabled.
    ///   - detentConfiguration: Contains the sizing options for the sheet
    ///   - uiConfiguration: Contains the configurable UI and interaction options
    ///   - completion: Default iOS completion call for presenting a viewController
    /// - Returns: A tuple which contains the sheet's sheetPresentationController and a dictionary which maps the defined detents to the corresponding iOS detents. You can use these two parameters to set the `selectedDetentIdentifier` of the sheet or perform additional configurations at any given point.
    @discardableResult
    public func presentBottomSheet<Content: View>(
        view: Content,
        detentConfiguration: DetentConfiguration,
        uiConfiguration: UIConfiguration,
        completion: (() -> Void)? = nil
    ) -> (sheetPresentationController: UISheetPresentationController?, detentToSheetDetentDictionary: [Detent : UISheetPresentationController.Detent])
    {
        let viewController: UIViewController
        if detentConfiguration.detents.hasSelfSizingDetent {
            viewController = RCSelfSizingHostingController(rootView: view)
        } else {
            viewController = UIHostingController(rootView: view)
        }

        return presentBottomSheet(
            viewController: viewController,
            detentConfiguration: detentConfiguration,
            uiConfiguration: uiConfiguration,
            completion: completion
        )
    }


    /// Presents a sheet over the given navigationController
    /// - Parameters:
    ///   - viewController: ViewController to present. Use `RCSelfSizingViewControllerProtocol` or `RCSelfSizingHostingController` in order to use `.selfSizing` detent.
    ///   - detentConfiguration: Contains the sizing options for the sheet
    ///   - uiConfiguration: Contains the configurable UI and interaction options
    ///   - completion: Default iOS completion call for presenting a viewController
    /// - Returns: A tuple which contains the sheet's sheetPresentationController and a dictionary which maps the defined detents to the corresponding iOS detents. You can use these two parameters to set the `selectedDetentIdentifier` of the sheet or perform additional configurations at any given point.
    @discardableResult
    public func presentBottomSheet(
        viewController: UIViewController,
        detentConfiguration: DetentConfiguration,
        uiConfiguration: UIConfiguration,
        completion: (() -> Void)? = nil
    ) -> (sheetPresentationController: UISheetPresentationController?, detentToSheetDetentDictionary: [Detent : UISheetPresentationController.Detent])
    {
        Self.presentBottomSheet(
            presentOn: navigationController,
            present: viewController,
            detentConfiguration: detentConfiguration,
            uiConfiguration: uiConfiguration,
            completion: completion
        )
    }

    /// Presents a sheet over the `presentOn` viewController
    /// - Parameters:
    ///   - presentOn: The ViewController (or NavigationController) you want the sheet to be presentedOn
    ///   - present: ViewController to present. Use `RCSelfSizingViewControllerProtocol` or `RCSelfSizingHostingController` in order to use `.selfSizing` detent.
    ///   - detentConfiguration: Contains the sizing options for the sheet
    ///   - uiConfiguration: Contains the configurable UI and interaction options
    ///   - completion: Default iOS completion call for presenting a viewController
    /// - Returns: A tuple which contains the sheet's sheetPresentationController and a dictionary which maps the defined detents to the corresponding iOS detents. You can use these two parameters to set the `selectedDetentIdentifier` of the sheet or perform additional configurations at any given point.
    @discardableResult
    public static func presentBottomSheet(
        presentOn viewControllerToPresentFrom: UIViewController,
        present viewControllerToPresent: UIViewController,
        detentConfiguration: DetentConfiguration,
        uiConfiguration: UIConfiguration,
        completion: (() -> Void)? = nil
    ) -> (sheetPresentationController: UISheetPresentationController?, detentToSheetDetentDictionary: [Detent : UISheetPresentationController.Detent])
    {
        // Set the presentation style for the bottom sheet
        viewControllerToPresent.modalPresentationStyle = .pageSheet
        viewControllerToPresent.isModalInPresentation = !uiConfiguration.enableInteractiveDismiss
        /// - Warning: SheetControler must be defined after setting the modalPresentationStyle
        let sheetController = viewControllerToPresent.sheetPresentationController
        sheetController?.prefersGrabberVisible = uiConfiguration.showsGrabIndicator
        sheetController?.preferredCornerRadius = uiConfiguration.preferredCornerRadius

        var localDetents = detentConfiguration.detents
        replaceWithFallbackDetentsIfNeeded(&localDetents)
        localDetents = Array(Set(localDetents)) // Remove the duplicate detents

        var selfSizingTuple: (selfSizingDetentIndex: Int, selfSizingDetent: Detent)?

        /// Configure the selfSizing detent if the viewController conforms to `RCSelfSizingViewControllerProtocol`
        if ios16Plus, let selfSizingViewController = viewControllerToPresent as? RCSelfSizingViewControllerProtocol {
            let calculatedSelfSizingHeight = selfSizingViewController.preferredContentSize.height.rounded()
            selfSizingTuple = handleSelfSizingDetentIfExists(&localDetents, calculatedHeight: calculatedSelfSizingHeight)
        }

        /// Assign sheet detents
        /// - Warning: Make sure to always set the final detent values before querying for largestUndimmedDetent. This is need for detent identifiers to sustain and match.
        let sheetDetents = localDetents.compactMap(\.detent)
        let detentToSheetDetentDictionary = Dictionary(uniqueKeysWithValues: localDetents.enumerated().compactMap {
            if ios16Plus,
               $0.offset == selfSizingTuple?.selfSizingDetentIndex,
               let selfSizingDetent = selfSizingTuple?.selfSizingDetent
            {
                return (selfSizingDetent, sheetDetents[$0.offset])
            }
            return ($0.element, sheetDetents[$0.offset])
        })
        sheetController?.detents = sheetDetents

        if ios16Plus {
            handleLargestUndimmedDetent(
                sheetController: sheetController,
                type: detentConfiguration.largestUndimmedDetent,
                detents: localDetents,
                selfSizingDetentIndex: selfSizingTuple?.selfSizingDetentIndex
            )
        }

        // Present the view controller on the navigation controller
        viewControllerToPresentFrom.present(viewControllerToPresent, animated: true, completion: completion)
        return (sheetController, detentToSheetDetentDictionary)
    }


    /// Replaces ios16+ detents with their fallback values.
    private static func replaceWithFallbackDetentsIfNeeded(_ detents: inout [Detent]) {
        guard !ios16Plus else { return }

        detents = detents.compactMap { detent in
            switch detent {
            case .selfSizing(fallback: let fallBack), .custom(height: _, fallBack: let fallBack):
                if detents.contains(fallBack.detent) {
                    return nil
                }
                return fallBack.detent
            default:
                return detent
            }
        }
    }

    /// Replaces the `.selfSizing` detent type with a `.custom` type where its height is the calculated view height
    /// - Parameters:
    ///   - detents: The detents which are enabled.
    ///   - calculatedHeight: The estimated view height of the viewController
    /// - Returns: The detent created for selfSizing type. This could be helpful if you are planning to use its identifier to configure thing like largestUndimmedDetent
    private static func handleSelfSizingDetentIfExists(_ detents: inout [Detent], calculatedHeight: CGFloat) -> (selfSizingDetentIndex: Int, selfSizingDetent: Detent)? {
        guard let selfSizingDetentIndex = detents.firstIndex(where: { $0.isSelfSizingDetent }) else {
            return nil
        }

        switch detents[selfSizingDetentIndex] {
        case .selfSizing(fallback: let fallBack):
            let detent = Detent.custom(height: calculatedHeight, fallBack: fallBack)
            detents.remove(at: selfSizingDetentIndex)
            detents.insert(detent, at: selfSizingDetentIndex)
            return (selfSizingDetentIndex, .selfSizing(fallback: fallBack))

        default:
            return nil
        }
    }

    /// Assigns the `largestUndimmedDetentIdentifier` for the current configuration if enabled.
    private static func handleLargestUndimmedDetent(sheetController: UISheetPresentationController?, type: DetentConfiguration.UndimmedDetentStyle, detents: [Detent], selfSizingDetentIndex: Int?) {
        if #available(iOS 16.0, *) {
            guard let sheetController else { return }

            switch type {
            case .selfSized:
                guard let selfSizingDetentIndex else { break }
                sheetController.largestUndimmedDetentIdentifier = sheetController.detents[selfSizingDetentIndex].identifier
            case .detent(let customDetent):
                guard let detentIndex = detents.firstIndex(of: customDetent) else { break }
                sheetController.largestUndimmedDetentIdentifier = sheetController.detents[detentIndex].identifier
            case .none:
                break
            }
        }
    }
}
