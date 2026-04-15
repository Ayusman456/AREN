//
//  DailyOutfit.swift
//  AREN
//
//  Created by Ayusman sahu on 14/04/26.
//

struct DailyOutfit {
    let top: WardrobeItem?
    let bottom: WardrobeItem?
    let shoes: WardrobeItem?

    var isEmpty: Bool {
        top == nil && bottom == nil && shoes == nil
    }

    var items: [WardrobeItem] {
        [top, bottom, shoes].compactMap { $0 }
    }
}
