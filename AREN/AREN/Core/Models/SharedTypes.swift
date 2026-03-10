import Foundation

enum WardrobeMode: String, Codable, CaseIterable {
    case western
    case ethnic
    case both
}

enum ClothingOccasion: String, Codable, CaseIterable {
    case casual
    case formal
    case ethnic
    case party
}

enum StyleBoardItemStatus: String, Codable, CaseIterable {
    case saved
    case inCart = "in_cart"
    case purchased
}

struct WeatherSnapshot: Codable, Sendable {
    var temperature: Double?
    var humidity: Double?
    var city: String?

    init(
        temperature: Double? = nil,
        humidity: Double? = nil,
        city: String? = nil
    ) {
        self.temperature = temperature
        self.humidity = humidity
        self.city = city
    }
}
