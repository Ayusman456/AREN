//
//  DailyOutfit.swift
//  AREN
//

import Foundation

struct DailyOutfit {
    let id: UUID
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
