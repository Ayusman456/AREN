import UIKit
import Vision

// MARK: - VisionBGRemover
// On-device background removal using VNGenerateForegroundInstanceMaskRequest.
// Returns a tight-cropped sticker PNG with transparent background.
// Runs on background thread, calls back on MainActor.

enum VisionBGRemoverError: Error {
    case requestFailed
    case maskGenerationFailed
    case outputRenderFailed
}

struct VisionBGRemover {

    // MARK: - Public

    static func process(
        image: UIImage,
        completion: @escaping @MainActor (Result<UIImage, Error>) -> Void
    ) {
        guard let cgImage = image.cgImage else {
            Task { @MainActor in completion(.failure(VisionBGRemoverError.requestFailed)) }
            return
        }

        Task.detached(priority: .userInitiated) {
            do {
                let result = try await removeBackground(from: cgImage, orientation: image.imageOrientation)
                await completion(.success(result))
            } catch {
                await completion(.failure(error))
            }
        }
    }

    // MARK: - Private

    private static func removeBackground(
        from cgImage: CGImage,
        orientation: UIImage.Orientation
    ) async throws -> UIImage {

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: cgImageOrientation(from: orientation),
            options: [:]
        )

        try handler.perform([request])

        guard let result = request.results?.first else {
            throw VisionBGRemoverError.maskGenerationFailed
        }

        // Generate masked image — all instances (full subject)
        let maskedBuffer = try result.generateMaskedImage(
            ofInstances: result.allInstances,
            from: handler,
            croppedToInstancesExtent: true  // tight crop — zero padding
        )

        guard let outputCGImage = CIContext().createCGImage(
            CIImage(cvPixelBuffer: maskedBuffer),
            from: CIImage(cvPixelBuffer: maskedBuffer).extent
        ) else {
            throw VisionBGRemoverError.outputRenderFailed
        }

        return UIImage(cgImage: outputCGImage)
    }

    // MARK: - Orientation helper

    private static func cgImageOrientation(from uiOrientation: UIImage.Orientation) -> CGImagePropertyOrientation {
        switch uiOrientation {
        case .up:            return .up
        case .down:          return .down
        case .left:          return .left
        case .right:         return .right
        case .upMirrored:    return .upMirrored
        case .downMirrored:  return .downMirrored
        case .leftMirrored:  return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default:    return .up
        }
    }
}//
//  VisionBGRemover.swift
//  AREN
//
//  Created by Ayusman sahu on 12/04/26.
//

