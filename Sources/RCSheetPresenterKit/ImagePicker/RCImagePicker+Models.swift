//
//  RCImagePicker+Models.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import UIKit
import PhotosUI

@available(iOS 14.0, *)
public enum RCImagePickerSource {
    case camera
    case photoLibrary
    /// Setting limit to `0` will enable unlimited selection.
    case phPhotoLibrary(selectionLimit: Int, filter: PHPickerFilter?)
}

@available(iOS 14.0, *)
public enum ImagePickerResult {
    case didSelectImage(UIImage)
    case failed(RCImagePickerError)
    case cancelled
}

@available(iOS 14.0, *)
public enum RCImagePickerError: Error {
    case sourceTypeUnavailable(RCImagePickerSource)
    case selectionFailed
    case noImageSelected
    case permissionDenied

    public var localizedDescription: String {
        switch self {
        case .sourceTypeUnavailable(let sourceType):
            return "The selected source type \(sourceType) is not available on this device."
        case .selectionFailed:
            return "Failed to select an image due to an unknown error."
        case .noImageSelected:
            return "No image was selected."
        case .permissionDenied:
            return "Permission to access the photo library or camera was denied."
        }
    }
}
