import Foundation
import Combine
import Supabase

// MARK: - Models

struct DailyOutfitRow: Decodable {
    let id: UUID
    let rank: Int
    let topId: UUID?
    let bottomId: UUID?
    let shoesId: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case rank
        case topId = "top_id"
        case bottomId = "bottom_id"
        case shoesId = "shoes_id"
    }
}

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var tops: [WardrobeItem] = []
    @Published var bottoms: [WardrobeItem] = []
    @Published var shoes: [WardrobeItem] = []

    @Published var topIndex: Int = 0
    @Published var bottomIndex: Int = 0
    @Published var shoesIndex: Int = 0

    @Published var reasoningText: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    // MARK: - Demo Fallback Constants

    private enum Demo {
        static let top = "shirt_001"
        static let bottom = "trouser_001"
        static let shoes = "shoes_001"
    }

    // MARK: - Private

    private let client = SupabaseService.shared.client
    private let totalOutfits = 8

    // MARK: - Public

    func loadOutfit() async {
        isLoading = true
        error = nil

        guard let userID = await SupabaseService.shared.currentUserID() else {
            loadDemoFallback()
            isLoading = false
            return
        }

        do {
            let fetchedTops = try await fetchItems(category: "Tops")
            let fetchedBottoms = try await fetchItems(category: "Bottoms")
            let fetchedShoes = try await fetchItems(category: "Shoes")

            // If wardrobe is empty, fall back to demo
            guard !fetchedTops.isEmpty || !fetchedBottoms.isEmpty || !fetchedShoes.isEmpty else {
                loadDemoFallback()
                isLoading = false
                return
            }

            tops = fetchedTops
            bottoms = fetchedBottoms
            shoes = fetchedShoes

            // Load or generate today's start indices
            let today = todayString()
            let existing: [DailyOutfitRow] = try await client
                .from("daily_outfits")
                .select()
                .eq("user_id", value: userID)
                .eq("date", value: today)
                .order("rank", ascending: true)
                .execute()
                .value

            if let first = existing.first {
                // Use persisted indices
                topIndex = tops.firstIndex(where: { $0.id == first.topId }) ?? 0
                bottomIndex = bottoms.firstIndex(where: { $0.id == first.bottomId }) ?? 0
                shoesIndex = shoes.firstIndex(where: { $0.id == first.shoesId }) ?? 0
            } else {
                // Generate and persist
                try await generateAndPersist(userID: userID, date: today)
            }

        } catch {
            self.error = error.localizedDescription
            loadDemoFallback()
        }

        isLoading = false
    }

    // MARK: - Private Helpers

    private func fetchItems(category: String) async throws -> [WardrobeItem] {
        try await client
            .from("clothing_items")
            .select()
            .eq("category", value: category)
            .execute()
            .value
    }

    private func generateAndPersist(userID: UUID, date: String) async throws {
        // Set random start indices
        topIndex = tops.indices.randomElement() ?? 0
        bottomIndex = bottoms.indices.randomElement() ?? 0
        shoesIndex = shoes.indices.randomElement() ?? 0

        // Persist 8 combinations to daily_outfits
        var rows: [[String: AnyJSON]] = []
        for rank in 1...totalOutfits {
            let row: [String: AnyJSON] = [
                "user_id": .string(userID.uuidString),
                "date": .string(date),
                "rank": .double(Double(rank)),
                "top_id": tops.indices.randomElement().map { .string(tops[$0].id.uuidString) } ?? .null,
                "bottom_id": bottoms.indices.randomElement().map { .string(bottoms[$0].id.uuidString) } ?? .null,
                "shoes_id": shoes.indices.randomElement().map { .string(shoes[$0].id.uuidString) } ?? .null
            ]
            rows.append(row)
        }

        try await client
            .from("daily_outfits")
            .insert(rows)
            .execute()
    }

    private func loadDemoFallback() {
        tops = [WardrobeItem(id: UUID(), category: "Tops", imageURL: nil, assetName: Demo.top)]
        bottoms = [WardrobeItem(id: UUID(), category: "Bottoms", imageURL: nil, assetName: Demo.bottom)]
        shoes = [WardrobeItem(id: UUID(), category: "Shoes", imageURL: nil, assetName: Demo.shoes)]
        topIndex = 0
        bottomIndex = 0
        shoesIndex = 0
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
