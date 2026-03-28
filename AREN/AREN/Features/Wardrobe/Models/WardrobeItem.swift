import Foundation

struct WardrobeItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var category: String
    var productCode: String
    var colorNote: String
}
