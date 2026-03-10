import Foundation
import SwiftData

enum ARENDataModel {
    static let schema = Schema([
        AppUser.self,
        ClothingItem.self,
        Outfit.self,
        OutfitItem.self,
        OutfitHistory.self,
        StyleBoard.self,
        StyleBoardItem.self,
    ])

    static let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
}
