//
//  RCImagePicker+CoordinatorHandler.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import UIKit
import PhotosUI

@available(iOS 14.0, *)
final class ImagePickerCoordinatorHandler: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate {
    private var completion: ((ImagePickerResult) -> Void) = { _ in }

    func presentImagePicker(
        on viewController: UIViewController,
        sourceType: RCImagePickerSource,
        completion: @escaping (ImagePickerResult) -> Void
    ) {
        self.completion = completion

        switch sourceType {
        case .camera:
            presentCamera(on: viewController)
        case .photoLibrary:
            presentImagePicker(on: viewController)
        case .phPhotoLibrary(let selectionLimit, let filter):
            presentPHPhotoLibrary(on: viewController, selectionLimit: selectionLimit, filter: filter)
        }
    }

    private func presentCamera(on viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            completion(.failed(.sourceTypeUnavailable(.camera)))
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        picker.allowsEditing = true
        viewController.present(picker, animated: true, completion: nil)
    }

    private func presentImagePicker(on viewController: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            completion(.failed(.sourceTypeUnavailable(.photoLibrary)))
            return
        }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        viewController.present(picker, animated: true, completion: nil)
    }


    private func presentPHPhotoLibrary(on viewController: UIViewController, selectionLimit: Int, filter: PHPickerFilter?) {
        var config = PHPickerConfiguration()
        config.selectionLimit = selectionLimit
        config.filter = filter // E.g., .images, .videos, or nil for any

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        viewController.present(picker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate Methods (for Camera)
@available(iOS 14.0, *)
extension ImagePickerCoordinatorHandler {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let selectedImage = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            completion(.didSelectImage(selectedImage))
        } else {
            completion(.failed(.noImageSelected))
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        completion(.cancelled)
    }
}

    // MARK: - PHPickerViewControllerDelegate (for Photo Library)

@available(iOS 14.0, *)
extension ImagePickerCoordinatorHandler {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard let result = results.first, result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            completion(.failed(.noImageSelected))
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.completion(.failed(.selectionFailed))
                    print("Error loading image: \(error.localizedDescription)")
                    return
                }

                if let image = object as? UIImage {
                    self?.completion(.didSelectImage(image))
                } else {
                    self?.completion(.failed(.selectionFailed))
                }
            }
        }
    }
}
