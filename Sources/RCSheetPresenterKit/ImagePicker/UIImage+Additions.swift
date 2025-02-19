//
//  UIImage+Additions.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import UIKit

extension UIImage {
    /// Compresses the image to meet a specified maximum file size in megabytes.
    /// - Parameters:
    ///   - maxFileSizeInMB: The maximum file size in megabytes (MB).
    ///   - preferredCompression: The initial compression quality (default is 0.7).
    ///   - compressionStep: The step by which to reduce compression quality (default is 0.1).
    /// - Returns: The compressed image data or `nil` if compression fails.
    func compressToJpeg(
        maxFileSizeInMB: Double? = nil,
        preferredCompression: CGFloat = 0.7,
        compressionStep: CGFloat = 0.1
    ) -> Data? {
        // Start with the preferred compression
        var compression = preferredCompression
        guard var imageData = self.jpegData(compressionQuality: compression) else { return nil }

        // Check if there is a maxFileSize requirement if not return the compressed image
        guard let maxFileSizeInMB else {
            return imageData
        }

        // Convert maxFileSize from megabytes to bytes
        let maxFileSizeInBytes = Int(maxFileSizeInMB * 1_048_576.0)
        // If the preferred compression is too large, adjust downward
        while imageData.count > maxFileSizeInBytes && compression > 0 {
            compression -= compressionStep
            autoreleasepool {
                guard let newData = self.jpegData(compressionQuality: compression) else { return }
                imageData = newData
            }
        }

        // If no valid compression achieved, return data at the preferred quality as a fallback
        if imageData.count > maxFileSizeInBytes {
            return autoreleasepool {
                return self.jpegData(compressionQuality: preferredCompression)
            }
        }

        return imageData
    }
}
