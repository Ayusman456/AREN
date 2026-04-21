//
//  WardrobeViewModel.swift
//  AREN
//

import Foundation
import Supabase
import Combine

@MainActor
final class WardrobeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var items: [WardrobeItem] = []
    @Published var outfits: [DailyOutfit] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var wornCounts: [UUID: Int] = [:]
    @Published var itemFilters: [String: String] = [:]
    @Published var outfitFilters: [String: String] = [:]
    @Published var activeTab: WardrobeTab = .items

    // MARK: - Private

    private let client = SupabaseService.shared.client

    // MARK: - Fetch Items

    func fetchItems() async {
        isLoading = true
        error = nil

        do {
            let response: [WardrobeItem] = try await client
                .from("clothing_items")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            items = response
            await loadWornCounts()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Fetch Outfits

    func fetchOutfits() async {
        guard !items.isEmpty else { return }

        isLoading = true
        error = nil

        do {
            let rows: [DailyOutfitRow] = try await client
                .from("daily_outfits")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            let itemLookup: [UUID: WardrobeItem] = Dictionary(
                uniqueKeysWithValues: items.map { ($0.id, $0) }
            )

            let dateParser = ISO8601DateFormatter()
            dateParser.formatOptions = [.withFullDate, .withDashSeparatorInDate]

            let fallbackDate = Date()

            outfits = rows.map { row in
                let parsedDate: Date = dateParser.date(from: row.date) ?? fallbackDate

                return DailyOutfit(
                    id: row.id,
                    date: parsedDate,
                    occasion: row.occasion,
                    top: row.topId.flatMap { itemLookup[$0] },
                    bottom: row.bottomId.flatMap { itemLookup[$0] },
                    shoes: row.shoesId.flatMap { itemLookup[$0] },
                    reasoningText: row.reasoningText
                )
            }
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Worn Counts

    private func loadWornCounts() async {
        do {
            let logs: [[String: String]] = try await client
                .from("wear_log")
                .select("item_id")
                .execute()
                .value

            var counts: [UUID: Int] = [:]
            for log in logs {
                if let raw = log["item_id"], let id = UUID(uuidString: raw) {
                    counts[id, default: 0] += 1
                }
            }
            wornCounts = counts
        } catch {
            wornCounts = [:]
        }
    }

    // MARK: - Filtered Items

    var filteredItems: [WardrobeItem] {
        var result = items

        if let sort = itemFilters["01-sort by"] {
            switch sort {
            case "A–Z":
                result = result.sorted { $0.name < $1.name }
            case "Brand":
                result = result.sorted { ($0.brand ?? "") < ($1.brand ?? "") }
            default:
                break
            }
        }

        if let status = itemFilters["02-status"], status != "All" {
            switch status {
            case "Worn":   result = result.filter { (wornCounts[$0.id] ?? 0) > 0 }
            case "Unworn": result = result.filter { (wornCounts[$0.id] ?? 0) == 0 }
            default:       break
            }
        }

        if let occasion = itemFilters["03-occasion"], occasion != "All" {
            result = result.filter {
                $0.occasion?.caseInsensitiveCompare(occasion) == .orderedSame
            }
        }

        return result
    }

    // MARK: - Filtered Outfits

    var filteredOutfits: [DailyOutfit] {
        var result = outfits

        if let sort = outfitFilters["01-sort by"] {
            switch sort {
            case "Date":
                result = result.sorted { $0.date > $1.date }
            default:
                break
            }
        }

        if let occasion = outfitFilters["02-occasion"], occasion != "All" {
            result = result.filter {
                $0.occasion?.caseInsensitiveCompare(occasion) == .orderedSame
            }
        }

        return result
    }
}
