//
//  RCDocumentPicker.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//


import UIKit
import UniformTypeIdentifiers

public protocol RCDocumentPickerPresenter: AnyObject {
    func presentDocumentPicker(
        on viewController: UIViewController,
        allowedTypes: [UTType],
        allowsMultipleSelection: Bool,
        completion: @escaping (RCDocumentPickerResult) -> Void
    )
}

private var documentPickerCoordinatorHandler: RCDocumentPickerCoordinatorHandler?

extension RCDocumentPickerPresenter {
    private func makeCoordinator() -> RCDocumentPickerCoordinatorHandler {
        RCDocumentPickerCoordinatorHandler()
    }

    private func resetCoordinator() {
        documentPickerCoordinatorHandler = nil
    }

    func presentDocumentPicker(
        on viewController: UIViewController,
        allowedTypes: [UTType],
        allowsMultipleSelection: Bool = false,
        completion: @escaping (RCDocumentPickerResult) -> Void
    ) {
        documentPickerCoordinatorHandler = makeCoordinator()
        documentPickerCoordinatorHandler?.presentDocumentPicker(
            on: viewController,
            allowedTypes: allowedTypes,
            allowsMultipleSelection: allowsMultipleSelection,
            completion: {
                defer { self.resetCoordinator() }
                completion($0)
            }
        )
    }
}
