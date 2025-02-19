//
//  RCDocumentPicker+CoordinatorHandler.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//


import UIKit
import UniformTypeIdentifiers

final class RCDocumentPickerCoordinatorHandler: NSObject, UIDocumentPickerDelegate {
    private var completion: ((RCDocumentPickerResult) -> Void) = { _ in }

    func presentDocumentPicker(
        on viewController: UIViewController,
        allowedTypes: [UTType],
        allowsMultipleSelection: Bool,
        completion: @escaping (RCDocumentPickerResult) -> Void
    ) {
        self.completion = completion

        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
        documentPicker.allowsMultipleSelection = allowsMultipleSelection
        documentPicker.delegate = self
        viewController.present(documentPicker, animated: true, completion: nil)
    }

    // MARK: - UIDocumentPickerDelegate Methods

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true, completion: nil)
        completion(.didSelectDocuments(urls))
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
        completion(.cancelled)
    }
}

