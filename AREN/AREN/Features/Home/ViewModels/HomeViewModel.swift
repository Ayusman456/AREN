//
//  HomeViewModel.swift
//  AREN
//
//  Created by Ayusman Sahu on 14/04/26.
//

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
    let isConfirmed: Bool
    let reasoningText: String?
    let date: String
    let occasion: String?

    enum CodingKeys: String, CodingKey {
        case id, rank
        case topId         = "top_id"
        case bottomId      = "bottom_id"
        case shoesId       = "shoes_id"
        case isConfirmed   = "is_confirmed"
        case reasoningText = "reasoning_text"
        case date
        case occasion
    }
}

struct WearLogRow: Decodable {
    let id: UUID
    let outfitId: UUID?

    enum CodingKeys: String, CodingKey {
        case id
        case outfitId = "outfit_id"
    }
}

// MARK: - Confirmation Button State

enum ConfirmOutfitCTAState: Equatable {
    case `default`
    case loading
    case confirmed
    case duplicate
    case error
}

// MARK: - Typed Error

enum HomeError: LocalizedError {
    case notAuthenticated
    case fetchFailed(underlying: Error)
    case persistFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:       return "You're not signed in. Showing demo outfits."
        case .fetchFailed(let e):     return "Couldn't load your wardrobe: \(e.localizedDescription)"
        case .persistFailed(let e):   return "Couldn't save today's outfit: \(e.localizedDescription)"
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

    @Published var currentRank: Int = 1

    @Published var displayCaption: String = "Your outfit for today"
    @Published var isLoading: Bool        = false
    @Published var error: HomeError?      = nil
    @Published var isOutfitSaved: Bool    = false

    @Published private(set) var isLoadingConfirmation: Bool = false
    @Published private(set) var confirmationError: Error?   = nil

    // MARK: - Private

    private let client       = SupabaseService.shared.client
    private let totalOutfits = 8
    private var loadTask: Task<Void, Never>?
    private var hasLoaded    = false

    private var outfitRowIDs: [Int: UUID]                        = [:]
    private var outfitCombinations: [Int: (UUID?, UUID?, UUID?)] = [:]
    private var outfitReasoningTexts: [Int: String]              = [:]
    private var outfitDates: [Int: String]                       = [:]
    private var outfitOccasions: [Int: String?]                  = [:]
    private var confirmedOutfitIDs: Set<UUID>                    = []

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

    // MARK: - Computed CTA State

    var confirmCTAState: ConfirmOutfitCTAState {
        if isLoadingConfirmation { return .loading }
        if confirmationError != nil { return .error }
        if isCurrentRankConfirmed { return .confirmed }
        if isCurrentCombinationDuplicate { return .duplicate }
        return .default
    }

    private var isCurrentRankConfirmed: Bool {
        guard let rowID = outfitRowIDs[currentRank] else { return false }
        return confirmedOutfitIDs.contains(rowID)
    }

    private var isCurrentCombinationDuplicate: Bool {
        let topId    = tops.indices.contains(topIndex)       ? tops[topIndex].id       : nil
        let bottomId = bottoms.indices.contains(bottomIndex) ? bottoms[bottomIndex].id : nil
        let shoesId  = shoes.indices.contains(shoesIndex)    ? shoes[shoesIndex].id    : nil

        for (rank, combo) in outfitCombinations {
            guard rank != currentRank else { continue }
            guard confirmedOutfitIDs.contains(outfitRowIDs[rank] ?? UUID()) else { continue }
            if combo.0 == topId && combo.1 == bottomId && combo.2 == shoesId { return true }
        }
        return false
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

        guard !Task.isCancelled else { isLoading = false; return }

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

            await loadConfirmedOutfitIDs(userID: userID)

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
                    for row in existing {
                        outfitRowIDs[row.rank]       = row.id
                        outfitCombinations[row.rank] = (row.topId, row.bottomId, row.shoesId)
                        outfitDates[row.rank]        = row.date
                        outfitOccasions[row.rank]    = row.occasion
                        if let text = row.reasoningText {
                            outfitReasoningTexts[row.rank] = text
                        }
                    }

                    if let first = existing.first {
                        topIndex    = tops.firstIndex(where: { $0.id == first.topId })       ?? firstAvailableIndex(in: tops)
                        bottomIndex = bottoms.firstIndex(where: { $0.id == first.bottomId }) ?? firstAvailableIndex(in: bottoms)
                        shoesIndex  = shoes.firstIndex(where: { $0.id == first.shoesId })    ?? firstAvailableIndex(in: shoes)
                        currentRank = 1
                    }

                    updateCaption(for: 1)

                } else {
                    try await generateAndPersist(userID: userID, date: today)
                    if let outfitId = outfitRowIDs[1] {
                        Task { await generateReasoning(outfitId: outfitId, rank: 1) }
                    }
                }
            } catch {
                applyLocalOutfitSelectionFallback()
                print("HomeViewModel daily_outfits fetch/persist failed: \(error)")
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

    // MARK: - Caption

    private func updateCaption(for rank: Int) {
        if let stored = outfitReasoningTexts[rank] {
            displayCaption = stored
        } else {
            displayCaption = "Your outfit for today"
            if let outfitId = outfitRowIDs[rank] {
                Task { await generateReasoning(outfitId: outfitId, rank: rank) }
            }
        }
    }

    // MARK: - Generate Reasoning via Edge Function

    private func generateReasoning(outfitId: UUID, rank: Int) async {
        guard let url = URL(string: "https://gtfysakpjifzypytxguw.supabase.co/functions/v1/generate-reasoning") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \((try? SupabaseConfiguration.load())?.anonKey ?? "")", forHTTPHeaderField: "Authorization")
        let body = ["outfit_id": outfitId.uuidString]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let rawString = String(data: data, encoding: .utf8) ?? "nil"
            print("📦 Edge Function response: \(rawString)")

            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                print("❌ HTTP \(http.statusCode)")
                return
            }

            struct ReasoningResponse: Decodable { let reasoning: String }
            let decoded = try JSONDecoder().decode(ReasoningResponse.self, from: data)
            outfitReasoningTexts[rank] = decoded.reasoning
            if currentRank == rank { displayCaption = decoded.reasoning }

        } catch {
            print("❌ generateReasoning error: \(error)")
        }
    }

    // MARK: - Load Confirmed Outfit IDs

    private func loadConfirmedOutfitIDs(userID: UUID) async {
        let todayStart = todayString() + "T00:00:00+00:00"
        do {
            let logs: [WearLogRow] = try await client
                .from("wear_log")
                .select("id, outfit_id")
                .eq("user_id", value: userID.uuidString)
                .gte("worn_at", value: todayStart)
                .execute()
                .value

            confirmedOutfitIDs = Set(logs.compactMap { $0.outfitId })
        } catch {
            print("HomeViewModel wear_log fetch failed: \(error)")
        }
    }

    // MARK: - Switch Rank

    func switchToRank(_ rank: Int) {
        guard outfitRowIDs[rank] != nil else { return }
        currentRank = rank

        if let combo = outfitCombinations[rank] {
            topIndex    = tops.firstIndex(where: { $0.id == combo.0 })    ?? firstAvailableIndex(in: tops)
            bottomIndex = bottoms.firstIndex(where: { $0.id == combo.1 }) ?? firstAvailableIndex(in: bottoms)
            shoesIndex  = shoes.firstIndex(where: { $0.id == combo.2 })   ?? firstAvailableIndex(in: shoes)
        }

        updateCaption(for: rank)
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
        case tops, bottoms, shoes, other
    }

    private func normalizedCategory(for item: WardrobeItem) -> OutfitCategoryBucket {
        guard let rawCategory = item.category?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
              !rawCategory.isEmpty else { return .other }

        if matchesAnyKeyword(in: rawCategory, keywords: [
            "top", "tops", "shirt", "t-shirt", "tshirt", "tee", "blouse",
            "jacket", "coat", "hoodie", "sweater", "sweatshirt"
        ]) { return .tops }

        if matchesAnyKeyword(in: rawCategory, keywords: [
            "bottom", "bottoms", "trouser", "trousers", "pant", "pants",
            "jean", "jeans", "skirt", "shorts"
        ]) { return .bottoms }

        if matchesAnyKeyword(in: rawCategory, keywords: [
            "shoe", "shoes", "sneaker", "sneakers", "boot", "boots",
            "sandal", "sandals", "loafer", "loafers", "heel", "heels", "footwear"
        ]) { return .shoes }

        return .other
    }

    private func matchesAnyKeyword(in value: String, keywords: [String]) -> Bool {
        keywords.contains { value.contains($0) }
    }

    private func firstAvailableIndex(in items: [WardrobeItem]) -> Int {
        items.isEmpty ? 0 : items.startIndex
    }

    private func applyLocalOutfitSelectionFallback() {
        topIndex    = firstAvailableIndex(in: tops)
        bottomIndex = firstAvailableIndex(in: bottoms)
        shoesIndex  = firstAvailableIndex(in: shoes)
    }

    // MARK: - Generate & Persist

    private func generateAndPersist(userID: UUID, date: String) async throws {
        let topCount    = tops.count
        let bottomCount = bottoms.count
        let shoesCount  = shoes.count

        let firstTopIdx    = topCount    > 0 ? Int.random(in: 0..<topCount)    : 0
        let firstBottomIdx = bottomCount > 0 ? Int.random(in: 0..<bottomCount) : 0
        let firstShoesIdx  = shoesCount  > 0 ? Int.random(in: 0..<shoesCount)  : 0

        topIndex    = firstTopIdx
        bottomIndex = firstBottomIdx
        shoesIndex  = firstShoesIdx
        currentRank = 1

        var rows: [[String: AnyJSON]] = []

        for rank in 1...totalOutfits {
            let tIdx = topCount    > 0 ? (firstTopIdx    + rank - 1) % topCount    : 0
            let bIdx = bottomCount > 0 ? (firstBottomIdx + rank - 1) % bottomCount : 0
            let sIdx = shoesCount  > 0 ? (firstShoesIdx  + rank - 1) % shoesCount  : 0

            let rowID  = UUID()
            let topId  = tops.isEmpty    ? nil : tops[tIdx].id
            let botId  = bottoms.isEmpty ? nil : bottoms[bIdx].id
            let shoId  = shoes.isEmpty   ? nil : shoes[sIdx].id

            outfitRowIDs[rank]       = rowID
            outfitCombinations[rank] = (topId, botId, shoId)
            outfitDates[rank]        = date
            outfitOccasions[rank]    = nil

            let row: [String: AnyJSON] = [
                "id":           .string(rowID.uuidString),
                "user_id":      .string(userID.uuidString),
                "date":         .string(date),
                "rank":         .double(Double(rank)),
                "top_id":       tops.isEmpty    ? .null : .string(tops[tIdx].id.uuidString),
                "bottom_id":    bottoms.isEmpty ? .null : .string(bottoms[bIdx].id.uuidString),
                "shoes_id":     shoes.isEmpty   ? .null : .string(shoes[sIdx].id.uuidString),
                "is_confirmed": .bool(false)
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

    // MARK: - Confirm Outfit

    func confirmOutfit() async {
        guard !isLoadingConfirmation else { return }
        guard confirmCTAState == .default else { return }

        isLoadingConfirmation = true
        confirmationError     = nil

        let topId    = tops.indices.contains(topIndex)       ? tops[topIndex].id       : nil
        let bottomId = bottoms.indices.contains(bottomIndex) ? bottoms[bottomIndex].id : nil
        let shoesId  = shoes.indices.contains(shoesIndex)    ? shoes[shoesIndex].id    : nil

        let itemIds = [topId, bottomId, shoesId].compactMap { $0 }

        guard !itemIds.isEmpty,
              let userID = await SupabaseService.shared.currentUserID(),
              let outfitRowID = outfitRowIDs[currentRank] else {
            confirmationError = NSError(domain: "ConfirmOutfit", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing user, items, or outfit row"])
            isLoadingConfirmation = false
            return
        }

        do {
            let iso    = ISO8601DateFormatter()
            let wornAt = iso.string(from: Date())

            let wearLogEntries: [[String: AnyJSON]] = itemIds.map { itemId in
                [
                    "user_id":   .string(userID.uuidString),
                    "item_id":   .string(itemId.uuidString),
                    "outfit_id": .string(outfitRowID.uuidString),
                    "worn_at":   .string(wornAt)
                ]
            }

            try await client.from("wear_log").insert(wearLogEntries).execute()

            try await client
                .from("daily_outfits")
                .update(["is_confirmed": AnyJSON.bool(true)])
                .eq("id", value: outfitRowID.uuidString)
                .execute()

            confirmedOutfitIDs.insert(outfitRowID)

            isLoadingConfirmation = false
            UINotificationFeedbackGenerator().notificationOccurred(.success)

        } catch {
            confirmationError     = error
            isLoadingConfirmation = false
            UINotificationFeedbackGenerator().notificationOccurred(.error)
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
        currentRank = 1
    }

    // MARK: - Helpers

    private func todayString() -> String {
        HomeViewModel.dateFormatter.string(from: Date())
    }
}
