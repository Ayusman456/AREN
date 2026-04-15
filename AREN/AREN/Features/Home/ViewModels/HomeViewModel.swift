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

// MARK: - ViewModel

@MainActor
final class HomeViewModel: ObservableObject {

    @Published var outfits: [DailyOutfit] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    private let client = SupabaseService.shared.client
    private let totalOutfits = 8

    // MARK: - Public

    func fetchDailyOutfit() async {
        isLoading = true
        error = nil

        guard let userID = await SupabaseService.shared.currentUserID() else {
            error = "No active session."
            isLoading = false
            return
        }

        let today = todayString()

        do {
            let existing: [DailyOutfitRow] = try await client
                .from("daily_outfits")
                .select()
                .eq("user_id", value: userID)
                .eq("date", value: today)
                .order("rank", ascending: true)
                .execute()
                .value

            if !existing.isEmpty {
                outfits = await resolve(rows: existing)
            } else {
                let generated = try await generate(userID: userID, date: today)
                outfits = await resolve(rows: generated)
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Today's outfit (first in list)

    var dailyOutfit: DailyOutfit {
        outfits.first ?? DailyOutfit(top: nil, bottom: nil, shoes: nil)
    }

    // MARK: - Private

    private func generate(userID: UUID, date: String) async throws -> [DailyOutfitRow] {
        let tops = try await fetchItems(category: "Tops")
        let bottoms = try await fetchItems(category: "Bottoms")
        let shoes = try await fetchItems(category: "Shoes")

        var rows: [[String: AnyJSON]] = []

        for rank in 1...totalOutfits {
            let row: [String: AnyJSON] = [
                "user_id": .string(userID.uuidString),
                "date": .string(date),
                "rank": .double(Double(rank)),
                "top_id": tops.randomElement().map { .string($0.id.uuidString) } ?? .null,
                "bottom_id": bottoms.randomElement().map { .string($0.id.uuidString) } ?? .null,
                "shoes_id": shoes.randomElement().map { .string($0.id.uuidString) } ?? .null
            ]
            rows.append(row)
        }

        try await client
            .from("daily_outfits")
            .insert(rows)
            .execute()

        let inserted: [DailyOutfitRow] = try await client
            .from("daily_outfits")
            .select()
            .eq("user_id", value: userID)
            .eq("date", value: date)
            .order("rank", ascending: true)
            .execute()
            .value

        return inserted
    }

    private func fetchItems(category: String) async throws -> [WardrobeItem] {
        try await client
            .from("clothing_items")
            .select()
            .eq("category", value: category)
            .execute()
            .value
    }

    private func resolve(rows: [DailyOutfitRow]) async -> [DailyOutfit] {
        await withTaskGroup(of: (Int, DailyOutfit).self) { group in
            for row in rows {
                group.addTask {
                    async let top = self.fetchItem(id: row.topId)
                    async let bottom = self.fetchItem(id: row.bottomId)
                    async let shoes = self.fetchItem(id: row.shoesId)
                    let outfit = await DailyOutfit(top: top, bottom: bottom, shoes: shoes)
                    return (row.rank, outfit)
                }
            }

            var results: [(Int, DailyOutfit)] = []
            for await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }.map { $0.1 }
        }
    }

    private func fetchItem(id: UUID?) async -> WardrobeItem? {
        guard let id else { return nil }
        return try? await client
            .from("clothing_items")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
