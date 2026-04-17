import Foundation
import Combine
import Supabase
import UIKit

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
        case topId    = "top_id"
        case bottomId = "bottom_id"
        case shoesId  = "shoes_id"
    }
}

// MARK: - Typed Error

enum HomeError: LocalizedError {
    case notAuthenticated
    case fetchFailed(underlying: Error)
    case persistFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You're not signed in. Showing demo outfits."
        case .fetchFailed(let e):
            return "Couldn't load your wardrobe: \(e.localizedDescription)"
        case .persistFailed(let e):
            return "Couldn't save today's outfit: \(e.localizedDescription)"
        }
    }
}

// MARK: - Outfit Layout Constants

enum OutfitLayout {
    static let topsHeight: CGFloat            = 216
    static let bottomsHeight: CGFloat         = 246
    static let shoesHeight: CGFloat           = 93
    static let canvasWidth: CGFloat           = 280
    static let topsWidth: CGFloat             = 257
    static let bottomsWidth: CGFloat          = 233
    static let shoesWidth: CGFloat            = 95
    static let rowSpacing: CGFloat            = 8
    static let canvasVerticalPadding: CGFloat = 8
}

// MARK: - HomeViewModel

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var tops: [WardrobeItem]    = []
    @Published var bottoms: [WardrobeItem] = []
    @Published var shoes: [WardrobeItem]   = []

    @Published var topIndex: Int    = 0
    @Published var bottomIndex: Int = 0
    @Published var shoesIndex: Int  = 0

    @Published var displayCaption: String = "Your outfit for today"
    @Published var isLoading: Bool        = false
    @Published var error: HomeError?      = nil
    @Published var isOutfitSaved: Bool    = false

    // MARK: - Private

    private let client         = SupabaseService.shared.client
    private let totalOutfits   = 8
    private var loadTask: Task<Void, Never>?
    private var hasLoaded      = false

    // MARK: - Static Helpers (created once)

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale     = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static let resolvedCaptionFontName: String = {
        let candidates = ["HelveticaNowText-Light", "HelveticaNowText-Regular"]
        return candidates.first { UIFont(name: $0, size: 11) != nil } ?? ""
    }()

    // MARK: - Public API

    /// Primary entry point. Guards against duplicate loads.
    func loadOutfitIfNeeded() {
        guard !hasLoaded else { return }
        loadOutfit()
    }

    /// Force-reload — cancels any in-flight task and restarts.
    func loadOutfit() {
        loadTask?.cancel()
        loadTask = Task { await _loadOutfit() }
    }

    // MARK: - Private Load

    private func _loadOutfit() async {
        isLoading = true
        error     = nil

        guard !Task.isCancelled else {
            isLoading = false
            return
        }

        // Unauthenticated — demo fallback
        guard let userID = await SupabaseService.shared.currentUserID() else {
            loadDemoFallback()
            hasLoaded = true  // FIX 1: prevent re-load on every call
            isLoading = false
            return
        }

        do {
            let fetchedTops    = try await fetchItems(category: "Tops")
            let fetchedBottoms = try await fetchItems(category: "Bottoms")
            let fetchedShoes   = try await fetchItems(category: "Shoes")

            guard !Task.isCancelled else {
                isLoading = false
                return
            }

            // Empty wardrobe — demo fallback
            guard !fetchedTops.isEmpty || !fetchedBottoms.isEmpty || !fetchedShoes.isEmpty else {
                loadDemoFallback()
                hasLoaded = true  // FIX 1: prevent re-load on every call
                isLoading = false
                return
            }

            tops    = fetchedTops
            bottoms = fetchedBottoms
            shoes   = fetchedShoes

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
                topIndex    = tops.firstIndex(where: { $0.id == first.topId })       ?? 0
                bottomIndex = bottoms.firstIndex(where: { $0.id == first.bottomId }) ?? 0
                shoesIndex  = shoes.firstIndex(where: { $0.id == first.shoesId })    ?? 0
            } else {
                try await generateAndPersist(userID: userID, date: today)
            }

            hasLoaded = true

        } catch is CancellationError {
            // Silently abort — new load already in flight
        } catch {
            self.error = .fetchFailed(underlying: error)
            loadDemoFallback()
            hasLoaded = true  // FIX 1: prevent retry loop on persistent error
        }

        isLoading = false
    }

    // MARK: - Fetch

    private func fetchItems(category: String) async throws -> [WardrobeItem] {
        try await client
            .from("clothing_items")
            .select()
            .eq("category", value: category)
            .execute()
            .value
    }

    // MARK: - Generate & Persist
    // NOTE: Currently uses index-cycling to guarantee variety across 8 combinations.
    // Will be replaced with scoring pipeline (occasion + weather + colour harmony)
    // once clothing_items schema has formality_score, weight_category, color columns
    // and wear_log table exists. See: Notion — Home Screen Outfit Selection Logic.

    private func generateAndPersist(userID: UUID, date: String) async throws {
        // FIX 2: Cycle through indices to guarantee variety — no duplicate combinations
        let topCount    = tops.count
        let bottomCount = bottoms.count
        let shoesCount  = shoes.count

        // Rank-1 outfit: random starting point within each category
        let firstTopIdx    = topCount    > 0 ? Int.random(in: 0..<topCount)    : 0
        let firstBottomIdx = bottomCount > 0 ? Int.random(in: 0..<bottomCount) : 0
        let firstShoesIdx  = shoesCount  > 0 ? Int.random(in: 0..<shoesCount)  : 0

        topIndex    = firstTopIdx
        bottomIndex = firstBottomIdx
        shoesIndex  = firstShoesIdx

        var rows: [[String: AnyJSON]] = []

        for rank in 1...totalOutfits {
            // Cycle through available items — guarantees variety without repetition
            // until items are exhausted, then wraps around
            let tIdx = topCount    > 0 ? (firstTopIdx    + rank - 1) % topCount    : 0
            let bIdx = bottomCount > 0 ? (firstBottomIdx + rank - 1) % bottomCount : 0
            let sIdx = shoesCount  > 0 ? (firstShoesIdx  + rank - 1) % shoesCount  : 0

            let row: [String: AnyJSON] = [
                "user_id":   .string(userID.uuidString),
                "date":      .string(date),
                "rank":      .double(Double(rank)),
                "top_id":    tops.isEmpty    ? .null : .string(tops[tIdx].id.uuidString),
                "bottom_id": bottoms.isEmpty ? .null : .string(bottoms[bIdx].id.uuidString),
                "shoes_id":  shoes.isEmpty   ? .null : .string(shoes[sIdx].id.uuidString)
            ]
            rows.append(row)
        }

        do {
            try await client
                .from("daily_outfits")
                .insert(rows)
                .execute()
        } catch {
            throw HomeError.persistFailed(underlying: error)
        }
    }

    // MARK: - Demo Fallback

    private func loadDemoFallback() {
        tops = [
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0001-000000000001")!, category: "Tops",    imageURL: nil, assetName: "shirt_001"),
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0001-000000000002")!, category: "Tops",    imageURL: nil, assetName: "shirt_002"),
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0001-000000000003")!, category: "Tops",    imageURL: nil, assetName: "shirt_003")
        ]
        bottoms = [
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0002-000000000001")!, category: "Bottoms", imageURL: nil, assetName: "trouser_001"),
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0002-000000000002")!, category: "Bottoms", imageURL: nil, assetName: "trouser_002"),
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0002-000000000003")!, category: "Bottoms", imageURL: nil, assetName: "trouser_003"),
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0002-000000000004")!, category: "Bottoms", imageURL: nil, assetName: "trouser_004")
        ]
        shoes = [
            WardrobeItem(id: UUID(uuidString: "00000000-0000-0000-0003-000000000001")!, category: "Shoes",   imageURL: nil, assetName: "shoes_001")
        ]
        topIndex    = 0
        bottomIndex = 0
        shoesIndex  = 0
    }

    // MARK: - Helpers

    private func todayString() -> String {
        HomeViewModel.dateFormatter.string(from: Date())
    }
}
