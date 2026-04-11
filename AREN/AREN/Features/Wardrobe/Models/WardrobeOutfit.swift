import Foundation
//  WardrobeOutfit.swift
//  AREN
//
//  Created by Ayusman sahu on 12/04/26.
//

struct WardrobeOutfit: Identifiable {
    let id: UUID = UUID()
    let imageAssetName: String
    let occasionLabel: String
    let pieceCount: Int
}
