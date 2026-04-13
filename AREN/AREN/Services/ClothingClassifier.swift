import UIKit
import Vision

struct ClothingClassifier {

    static func classify(_ image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                guard error == nil,
                      let observations = request.results as? [VNClassificationObservation] else {
                    continuation.resume(returning: nil)
                    return
                }

                let category = mapToCategory(observations)
                continuation.resume(returning: category)
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])
        }
    }

    // MARK: - Map Vision labels → ARĒN categories

    private static func mapToCategory(_ observations: [VNClassificationObservation]) -> String? {
        let topLabels = observations
            .filter { $0.confidence > 0.1 }
            .prefix(10)
            .map { $0.identifier.lowercased() }

        let rules: [(keywords: [String], category: String)] = [
            (["shirt", "top", "blouse", "jacket", "coat", "hoodie", "sweater", "tshirt", "t-shirt"], "Tops"),
            (["trouser", "pant", "jeans", "shorts", "skirt", "bottom"], "Bottoms"),
            (["shoe", "sneaker", "boot", "sandal", "loafer", "footwear"], "Shoes"),
            (["bag", "watch", "belt", "cap", "hat", "scarf", "accessory"], "Accessories"),
        ]

        for rule in rules {
            for label in topLabels {
                if rule.keywords.contains(where: { label.contains($0) }) {
                    return rule.category
                }
            }
        }

        return nil
    }
}//
//  ClothingClassifier.swift
//  AREN
//
//  Created by Ayusman sahu on 13/04/26.
//

