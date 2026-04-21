//
//  DailyOutfit.swift
//  AREN
//

import Foundation

struct DailyOutfit: Identifiable {
    let id: UUID
    let date: Date
    let occasion: String?
    let top: WardrobeItem?
    let bottom: WardrobeItem?
    let shoes: WardrobeItem?
    let reasoningText: String?

    var isEmpty: Bool {
        top == nil && bottom == nil && shoes == nil
    }

    var items: [WardrobeItem] {
        [top, bottom, shoes].compactMap { $0 }
    }
}

// MARK: - Preview

#if DEBUG
extension DailyOutfit {
    static var preview: DailyOutfit {
        DailyOutfit(
            id: UUID(),
            date: Date(),
            occasion: "Casual",
            top: WardrobeItem(
                id: UUID(uuidString: "00000000-0000-0000-0001-000000000001")!,
                category: "Tops",
                imageURL: nil,
                assetName: "shirt_001"
            ),
            bottom: WardrobeItem(
                id: UUID(uuidString: "00000000-0000-0000-0002-000000000001")!,
                category: "Bottoms",
                imageURL: nil,
                assetName: "trouser_001"
            ),
            shoes: WardrobeItem(
                id: UUID(uuidString: "00000000-0000-0000-0003-000000000001")!,
                category: "Shoes",
                imageURL: nil,
                assetName: "shoes_001"
            ),
            reasoningText: "Your outfit for today"
        )
    }
}
#endif
