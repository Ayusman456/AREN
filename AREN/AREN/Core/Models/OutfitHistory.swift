import Foundation
import SwiftData

@Model
final class OutfitHistory {
    @Attribute(.unique) var id: UUID
    var wornAt: Date
    var occasion: ClothingOccasion?
    var weatherTemperature: Double?
    var weatherHumidity: Double?
    var weatherCity: String?

    var user: AppUser?
    var outfit: Outfit?

    init(
        id: UUID = UUID(),
        wornAt: Date = .now,
        occasion: ClothingOccasion? = nil,
        weatherTemperature: Double? = nil,
        weatherHumidity: Double? = nil,
        weatherCity: String? = nil,
        user: AppUser? = nil,
        outfit: Outfit? = nil
    ) {
        self.id = id
        self.wornAt = wornAt
        self.occasion = occasion
        self.weatherTemperature = weatherTemperature
        self.weatherHumidity = weatherHumidity
        self.weatherCity = weatherCity
        self.user = user
        self.outfit = outfit
    }
}
