//
//  RCActionSheetPresenter.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import UIKit

public protocol RCActionSheetPresenter {}

extension RCActionSheetPresenter {

    // Function to present an action sheet
    public func presentActionSheet(
        on viewController: UIViewController,
        title: String? = nil,
        message: String? = nil,
        actions: [RCActionSheetAction],
        showCancelButton: Bool = true,
        cancelButtonTitle: String = "Cancel"
    ) {
        guard !actions.isEmpty else {
            assertionFailure("Action sheet must contain at least one action.")
            return
        }

        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)

        for action in actions {
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                action.handler?()
            }
            actionSheet.addAction(alertAction)
        }

        // Add cancel action by default
        if showCancelButton {
            let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
            actionSheet.addAction(cancelAction)
        }

        // Present the action sheet
        viewController.present(actionSheet, animated: true, completion: nil)
    }
}

// Struct to define actions for the action sheet
public struct RCActionSheetAction {
    public let title: String
    public let style: UIAlertAction.Style
    public let handler: (() -> Void)?

    public init(title: String, style: UIAlertAction.Style = .default, handler: (() -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
