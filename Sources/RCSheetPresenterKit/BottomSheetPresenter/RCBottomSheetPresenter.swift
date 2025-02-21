//
//  RCBottomSheetPresenter.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import SwiftUI

public class RCBottomSheetPresenter {
    let navigationController: UINavigationController

    var ios16Plus: Bool = {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }()

    /// - Parameter navigationController: The navigationController in which the bottomSheet will be presented on.
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}

extension RCBottomSheetPresenter {

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

    @discardableResult
    public func presentBottomSheet(
        viewController: UIViewController,
        detentConfiguration: DetentConfiguration,
        uiConfiguration: UIConfiguration,
        completion: (() -> Void)? = nil
    ) -> (sheetPresentationController: UISheetPresentationController?, detentToSheetDetentDictionary: [Detent : UISheetPresentationController.Detent])
    {
        // Set the presentation style for the bottom sheet
        viewController.modalPresentationStyle = .pageSheet
        viewController.isModalInPresentation = !uiConfiguration.enableInteractiveDismiss
        /// - Warning: SheetControler must be defined after setting the modalPresentationStyle
        let sheetController = viewController.sheetPresentationController
        sheetController?.prefersGrabberVisible = uiConfiguration.showsGrabIndicator
        sheetController?.preferredCornerRadius = uiConfiguration.preferredCornerRadius

        var localDetents = Array(Set(detentConfiguration.detents))
        replaceWithFallbackDetentsIfNeeded(&localDetents)

        var selfSizingDetentIndex: Int?
        /// Configure the selfSizing detent if the viewController conforms to `RCSelfSizingViewControllerProtocol`
        if ios16Plus, let selfSizingViewController = viewController as? RCSelfSizingViewControllerProtocol {
            let calculatedSelfSizingHeight = selfSizingViewController.preferredContentSize.height.rounded()
            selfSizingDetentIndex = handleSelfSizingDetentIfExists(&localDetents, calculatedHeight: calculatedSelfSizingHeight)
        }

        /// Assign sheet detents
        /// - Warning: Make sure to always set the final detent values before querying for largestUndimmedDetent. This is need for detent identifiers to sustain and match.
        let sheetDetents = localDetents.compactMap(\.detent)
        let detentToSheetDetentDictionary = Dictionary(uniqueKeysWithValues: localDetents.enumerated().compactMap {
            if ios16Plus, $0.offset == selfSizingDetentIndex {
                return (detentConfiguration.detents[$0.offset], sheetDetents[$0.offset])
            }
            return ($0.element, sheetDetents[$0.offset])
        })
        sheetController?.detents = sheetDetents

        if ios16Plus {
            handleLargestUndimmedDetent(
                sheetController: sheetController,
                type: detentConfiguration.largestUndimmedDetent,
                detents: localDetents,
                selfSizingDetentIndex: selfSizingDetentIndex
            )
        }

        // Present the view controller on the navigation controller
        navigationController.present(viewController, animated: true, completion: completion)
        return (sheetController, detentToSheetDetentDictionary)
    }


    /// Replaces ios16+ detents with their fallback values.
    private func replaceWithFallbackDetentsIfNeeded(_ detents: inout [Detent]) {
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
    private func handleSelfSizingDetentIfExists(_ detents: inout [Detent], calculatedHeight: CGFloat) -> Int? {
        if let selfSizingDetentIndex = detents.firstIndex(of: .selfSizing(fallback: .medium)) {
            let detent = Detent.custom(height: calculatedHeight, fallBack: .medium)
            detents.remove(at: selfSizingDetentIndex)
            detents.insert(detent, at: selfSizingDetentIndex)
            return selfSizingDetentIndex
        } else if let selfSizingDetentIndex = detents.firstIndex(of: .selfSizing(fallback: .large)) {
            let detent = Detent.custom(height: calculatedHeight, fallBack: .large)
            detents.remove(at: selfSizingDetentIndex)
            detents.insert(detent, at: selfSizingDetentIndex)
            return selfSizingDetentIndex
        } else {
            return nil
        }
    }

    /// Assigns the `largestUndimmedDetentIdentifier` for the current configuration if enabled.
    private func handleLargestUndimmedDetent(sheetController: UISheetPresentationController?, type: DetentConfiguration.UndimmedDetentStyle, detents: [Detent], selfSizingDetentIndex: Int?) {
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
