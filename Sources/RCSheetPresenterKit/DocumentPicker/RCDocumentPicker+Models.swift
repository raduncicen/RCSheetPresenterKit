//
//  RCDocumentPicker+Models.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//
import Foundation

public enum RCDocumentPickerResult {
    case didSelectDocuments([URL])
    case failed(RCDocumentPickerError) // FIXME: Must be handled
    case cancelled
}

public enum RCDocumentPickerError: Error {
    case permissionDenied
    case selectionFailed
    case noDocumentSelected

    public var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "Permission to access the document picker was denied."
        case .selectionFailed:
            return "Failed to select a document due to an unknown error."
        case .noDocumentSelected:
            return "No document was selected."
        }
    }
}
