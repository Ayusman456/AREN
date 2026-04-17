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
        case id, rank
        case topId    = "top_id"
        case bottomId = "bottom_id"
        case shoesId  = "shoes_id"
    }
}

// MARK: - Confirmation Button State

enum ConfirmOutfitCTAState: Equatable {
    case `default`
    case loading
    case error
    case confirmed
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

    // Confirmation flow state
    @Published private(set) var isLoadingConfirmation: Bool = false
    @Published private(set) var confirmationError: Error?   = nil
    @Published private(set) var isConfirmed: Bool           = false

    // MARK: - Private

    private let client         = SupabaseService.shared.client
    private let totalOutfits   = 8
    private var loadTask: Task<Void, Never>?
    private var hasLoaded      = false
    private var todayOutfitRowID: UUID?  // Cache for confirm flow

    // MARK: - Static Helpers

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

    // MARK: - Computed State for View

    var confirmCTAState: ConfirmOutfitCTAState {
        if isLoadingConfirmation { return .loading }
        if confirmationError != nil { return .error }
        if isConfirmed { return .confirmed }
        return .default
    }

    // MARK: - Public API

    func loadOutfitIfNeeded() {
        guard !hasLoaded else { return }
        loadOutfit()
    }

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

        guard let userID = await SupabaseService.shared.currentUserID() else {
            loadDemoFallback()
            hasLoaded = true
            isLoading = false
            return
        }

        do {
            let fetchedItems   = try await fetchItems(userID: userID)
            let fetchedTops    = fetchedItems.filter { normalizedCategory(for: $0) == .tops }
            let fetchedBottoms = fetchedItems.filter { normalizedCategory(for: $0) == .bottoms }
            let fetchedShoes   = fetchedItems.filter { normalizedCategory(for: $0) == .shoes }

            guard !Task.isCancelled else { isLoading = false; return }

            guard !fetchedTops.isEmpty || !fetchedBottoms.isEmpty || !fetchedShoes.isEmpty else {
                loadDemoFallback()
                hasLoaded = true
                isLoading = false
                return
            }

            tops    = fetchedTops
            bottoms = fetchedBottoms
            shoes   = fetchedShoes

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

                if let first = existing.first {
                    self.todayOutfitRowID = first.id
                    topIndex    = tops.firstIndex(where: { $0.id == first.topId })       ?? firstAvailableIndex(in: tops)
                    bottomIndex = bottoms.firstIndex(where: { $0.id == first.bottomId }) ?? firstAvailableIndex(in: bottoms)
                    shoesIndex  = shoes.firstIndex(where: { $0.id == first.shoesId })    ?? firstAvailableIndex(in: shoes)
                } else {
                    do {
                        let outfitID = try await generateAndPersist(userID: userID, date: today)
                        self.todayOutfitRowID = outfitID
                    } catch {
                        self.todayOutfitRowID = nil
                        applyLocalOutfitSelectionFallback()
                        print("HomeViewModel daily_outfits persist failed, using local fallback: \(error)")
                    }
                }
            } catch {
                self.todayOutfitRowID = nil
                applyLocalOutfitSelectionFallback()
                print("HomeViewModel daily_outfits fetch failed, using local fallback: \(error)")
            }

            hasLoaded = true

        } catch is CancellationError {
            // Silently abort
        } catch {
            self.error = .fetchFailed(underlying: error)
            loadDemoFallback()
            hasLoaded = true
        }

        isLoading = false
    }

    // MARK: - Fetch

    private func fetchItems(userID: UUID) async throws -> [WardrobeItem] {
        try await client
            .from("clothing_items")
            .select()
            .eq("user_id", value: userID.uuidString)
            .execute()
            .value
    }

    private enum OutfitCategoryBucket {
        case tops
        case bottoms
        case shoes
        case other
    }

    private func normalizedCategory(for item: WardrobeItem) -> OutfitCategoryBucket {
        guard let rawCategory = item.category?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !rawCategory.isEmpty else {
            return .other
        }

        if matchesAnyKeyword(in: rawCategory, keywords: [
            "top", "tops", "shirt", "t-shirt", "tshirt", "tee", "blouse",
            "jacket", "coat", "hoodie", "sweater", "sweatshirt"
        ]) {
            return .tops
        }

        if matchesAnyKeyword(in: rawCategory, keywords: [
            "bottom", "bottoms", "trouser", "trousers", "pant", "pants",
            "jean", "jeans", "skirt", "shorts"
        ]) {
            return .bottoms
        }

        if matchesAnyKeyword(in: rawCategory, keywords: [
            "shoe", "shoes", "sneaker", "sneakers", "boot", "boots",
            "sandal", "sandals", "loafer", "loafers", "heel", "heels",
            "footwear"
        ]) {
            return .shoes
        }

        return .other
    }

    private func matchesAnyKeyword(in value: String, keywords: [String]) -> Bool {
        keywords.contains { value.contains($0) }
    }

    private func firstAvailableIndex(in items: [WardrobeItem]) -> Int {
        items.isEmpty ? 0 : items.startIndex
    }

    private func applyLocalOutfitSelectionFallback() {
        topIndex = firstAvailableIndex(in: tops)
        bottomIndex = firstAvailableIndex(in: bottoms)
        shoesIndex = firstAvailableIndex(in: shoes)
    }

    // MARK: - Generate & Persist

    private func generateAndPersist(userID: UUID, date: String) async throws -> UUID {
        let topCount    = tops.count
        let bottomCount = bottoms.count
        let shoesCount  = shoes.count

        let firstTopIdx    = topCount    > 0 ? Int.random(in: 0..<topCount)    : 0
        let firstBottomIdx = bottomCount > 0 ? Int.random(in: 0..<bottomCount) : 0
        let firstShoesIdx  = shoesCount  > 0 ? Int.random(in: 0..<shoesCount)  : 0

        topIndex    = firstTopIdx
        bottomIndex = firstBottomIdx
        shoesIndex  = firstShoesIdx

        var rows: [[String: AnyJSON]] = []
        var rankOneID: UUID?

        for rank in 1...totalOutfits {
            let tIdx = topCount    > 0 ? (firstTopIdx    + rank - 1) % topCount    : 0
            let bIdx = bottomCount > 0 ? (firstBottomIdx + rank - 1) % bottomCount : 0
            let sIdx = shoesCount  > 0 ? (firstShoesIdx  + rank - 1) % shoesCount  : 0

            var row: [String: AnyJSON] = [
                "user_id":   .string(userID.uuidString),
                "date":      .string(date),
                "rank":      .double(Double(rank)),
                "top_id":    tops.isEmpty    ? .null : .string(tops[tIdx].id.uuidString),
                "bottom_id": bottoms.isEmpty ? .null : .string(bottoms[bIdx].id.uuidString),
                "shoes_id":  shoes.isEmpty   ? .null : .string(shoes[sIdx].id.uuidString),
                "is_confirmed": .bool(false)
            ]
            if rank == 1 {
                // We'll capture the inserted ID via Supabase's returning clause if available,
                // otherwise we generate one proactively.
                rankOneID = UUID()
                row["id"] = .string(rankOneID!.uuidString)
            }
            rows.append(row)
        }

        do {
            try await client
                .from("daily_outfits")
                .insert(rows)
                .execute()

            return rankOneID ?? UUID()

        } catch {
            throw HomeError.persistFailed(underlying: error)
        }
    }

    // MARK: - Confirm Outfit

    func confirmOutfit() async {
        guard !isConfirmed, !isLoadingConfirmation else { return }
        
        await MainActor.run {
            self.isLoadingConfirmation = true
            self.confirmationError = nil
        }
        
        guard !Task.isCancelled else { return }
        
        let topId    = tops.indices.contains(topIndex)    ? tops[topIndex].id    : nil
        let bottomId = bottoms.indices.contains(bottomIndex) ? bottoms[bottomIndex].id : nil
        let shoesId  = shoes.indices.contains(shoesIndex)  ? shoes[shoesIndex].id  : nil
        
        let itemIds = [topId, bottomId, shoesId].compactMap { $0 }
        guard !itemIds.isEmpty, let userID = await SupabaseService.shared.currentUserID() else {
            await MainActor.run {
                self.isLoadingConfirmation = false
                self.confirmationError = NSError(domain: "ConfirmOutfit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing user or items"])
            }
            return
        }
        
        guard let outfitRowID = todayOutfitRowID else {
            await MainActor.run {
                self.isLoadingConfirmation = false
                self.confirmationError = NSError(domain: "ConfirmOutfit", code: -2, userInfo: [NSLocalizedDescriptionKey: "No outfit row to confirm"])
            }
            return
        }
        
        do {
            // Insert wear_log entries
            let iso = ISO8601DateFormatter()
            let wornAt = iso.string(from: Date())
            let wearLogEntries = itemIds.map { itemId in
                [
                    "user_id": AnyJSON.string(userID.uuidString),
                    "item_id": AnyJSON.string(itemId.uuidString),
                    "outfit_id": AnyJSON.string(outfitRowID.uuidString),
                    "worn_at":   AnyJSON.string(wornAt)
                ] as [String: AnyJSON]
            }
            
            if !wearLogEntries.isEmpty {
                try await client
                    .from("wear_log")
                    .insert(wearLogEntries)
                    .execute()
            }
            
            // Mark outfit confirmed
            try await client
                .from("daily_outfits")
                .update(["is_confirmed": AnyJSON.bool(true)])
                .eq("id", value: outfitRowID.uuidString)
                .execute()
            
            await MainActor.run {
                self.isConfirmed = true
                self.isLoadingConfirmation = false
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
            
        } catch {
            await MainActor.run {
                self.confirmationError = error
                self.isLoadingConfirmation = false
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
            print("confirmOutfit failed: \(error)")
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
        isConfirmed = false
    }

    // MARK: - Helpers

    private func todayString() -> String {
        HomeViewModel.dateFormatter.string(from: Date())
    }
}
