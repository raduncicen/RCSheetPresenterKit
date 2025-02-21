//
//  RCImagePicker.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import UIKit

@available(iOS 14.0, *)
private var imagePickerCoordinatorHandler: ImagePickerCoordinatorHandler?

@available(iOS 14.0, *)
public protocol RCImagePickerPresenter: AnyObject {
    func presentImagePicker(
        on viewController: UIViewController,
        sourceType: RCImagePickerSource,
        completion: @escaping (ImagePickerResult) -> Void
    )
}

@available(iOS 14.0, *)
extension RCImagePickerPresenter {
    private func makeCoordinator() -> ImagePickerCoordinatorHandler {
        ImagePickerCoordinatorHandler()
    }

    private func resetCoordinator() {
        imagePickerCoordinatorHandler = nil
    }

    public func presentImagePicker(
        on viewController: UIViewController,
        sourceType: RCImagePickerSource,
        completion: @escaping (ImagePickerResult) -> Void
    ){
        imagePickerCoordinatorHandler = makeCoordinator()
        imagePickerCoordinatorHandler?.presentImagePicker(
            on: viewController,
            sourceType: sourceType,
            completion: {
                defer { self.resetCoordinator() }
                completion($0)
            }
        )
    }
}


