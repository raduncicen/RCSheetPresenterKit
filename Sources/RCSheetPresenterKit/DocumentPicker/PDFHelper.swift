//
//  PDFHelper.swift
//  RCSheetPresenterKit
//
//  Created by Radun Çiçen on 19.02.2025.
//

import Foundation
import PDFKit
import UIKit
import CoreGraphics
import AVFoundation

public class PDFHelper {

    public func pdfDocument(url: URL) -> PDFDocument? {
        PDFDocument(url: url)
    }

    public func pdfDocument(data: Data) -> PDFDocument? {
        PDFDocument(data: data)
    }

    public func pageCount(pdfUrl: URL) -> Int? {
        PDFDocument(url: pdfUrl)?.pageCount
    }

    public func pageCount(pdfData: Data) -> Int? {
        PDFDocument(data: pdfData)?.pageCount
    }


    /// Converts PDF data into an array of UIImage objects.
    /// - Parameters:
    ///   - pdfData: The PDF data to be converted.
    ///   - compressionQuality: The quality of the images extracted (0.0 to 1.0).
    /// - Returns: An array of UIImage objects representing each page of the PDF.
    public func pdfImages(from pdfData: Data, compressionQuality: CGFloat = 1.0) -> [UIImage]? {
        autoreleasepool {
            guard let pdfDocument = PDFDocument(data: pdfData), pdfDocument.pageCount > 0 else {
                return nil
            }

            var images = [UIImage]()
            var lastPageSize: CGSize = .zero
            var renderer: UIGraphicsImageRenderer?

            for pageIndex in 0..<pdfDocument.pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else { continue }

                let pageRect = page.bounds(for: .mediaBox)
                let scaleFactor: CGFloat = 1.0

                // Reuse renderer when possible to prevent memory spike
                if renderer == nil || lastPageSize != pageRect.size {
                    let format = UIGraphicsImageRendererFormat()
                    format.scale = 1.0
                    renderer = UIGraphicsImageRenderer(size: pageRect.size, format: format)
                    lastPageSize = pageRect.size
                }

                autoreleasepool {
                    let image = renderer?.image { context in
                        UIColor.white.set()
                        context.fill(CGRect(origin: .zero, size: pageRect.size))
                        context.cgContext.translateBy(x: 0, y: pageRect.size.height)
                        context.cgContext.scaleBy(x: scaleFactor, y: -scaleFactor)
                        page.draw(with: .mediaBox, to: context.cgContext)
                    }

                    if let image = image, let compressedData = image.jpegData(compressionQuality: compressionQuality), let compressedImage = UIImage(data: compressedData) {
                        images.append(compressedImage)
                    }
                }
            }

            return images.isEmpty ? nil : images
        }
    }

    /// Converts an array of UIImage objects into PDF data.
    /// - Parameters:
    ///   - images: The array of UIImage objects to be converted.
    ///   - compressionQuality: The quality of the images within the PDF (0.0 to 1.0).
    /// - Returns: PDF data representing the images.
    public func pdfData(from images: [UIImage], compressionQuality: CGFloat = 1.0) -> Data? {
        autoreleasepool {
            let pdfPageBounds = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4 size at 72 DPI
            let renderer = UIGraphicsPDFRenderer(bounds: pdfPageBounds)

            let data = renderer.pdfData { context in
                for image in images {
                    autoreleasepool {
                        context.beginPage()
                        let imageRect = AVMakeRect(aspectRatio: image.size, insideRect: pdfPageBounds)

                        if let resizedImage = image.resize(to: imageRect.size), let compressedData = resizedImage.jpegData(compressionQuality: compressionQuality), let compressedImage = UIImage(data: compressedData) {
                            compressedImage.draw(in: imageRect)
                        } else {
                            image.draw(in: imageRect)
                        }
                    }
                }
            }

            return data.isEmpty ? nil : data
        }
    }

    public func compressPDF(_ originalURL: URL, compressionQuality: CGFloat = 0.8) -> (Data, [UIImage])? {
        guard let originalPdfData = try? Data(contentsOf: originalURL) else {
            return nil
        }
        guard let pdfImages = pdfImages(from: originalPdfData, compressionQuality: compressionQuality) else {
            return nil
        }
        guard let compressedPdfData = pdfData(from: pdfImages, compressionQuality: compressionQuality) else {
            return nil
        }
        return (compressedPdfData, pdfImages)
    }

    /// Presents a share sheet to share the PDF data.
    /// - Parameters:
    ///   - pdfData: The PDF data to be shared.
    ///   - viewController: The UIViewController from which to present the share sheet.
    public func presentShareSheet(forPDFData pdfData: Data, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)

        // Exclude irrelevant activity types if desired
        activityViewController.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .saveToCameraRoll,
            .print
        ]

        // For iPad: Set the sourceView and sourceRect to prevent crashes
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.sourceView = viewController.view
            popoverController.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }

        // Present the activity view controller on the main thread
        DispatchQueue.main.async {
            viewController.present(activityViewController, animated: true, completion: nil)
        }
    }
}

fileprivate extension UIImage {
    /// Resizes the image to the specified size.
    /// - Parameter targetSize: The desired size.
    /// - Returns: A new UIImage object with the specified size.
    func resize(to targetSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
