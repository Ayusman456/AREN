import Foundation
import Supabase
import Combine

@MainActor
final class WardrobeViewModel: ObservableObject {

    // MARK: - Published State

    @Published var items: [WardrobeItem] = []
    @Published var outfits: [WardrobeOutfit] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil
    @Published var wornCounts: [UUID: Int] = [:]
    @Published var itemFilters: [String: String] = [:]
    @Published var outfitFilters: [String: String] = [:]
    // Add to WardrobeViewModel
    @Published var activeTab: WardrobeTab = .items

    // MARK: - Private

    private let client = SupabaseService.shared.client

    // MARK: - Fetch

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
         //   print("occasions:", response.map { $0.occasion ?? "nil" }) debugging print
            await loadWornCounts()
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func fetchOutfits() async {
        isLoading = true
        error = nil

        do {
            let response: [WardrobeOutfit] = try await client
                .from("daily_outfits")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            outfits = response
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
            // Non-fatal — worn counts default to empty, Status filter treats all as unworn
            wornCounts = [:]
        }
    }

    // MARK: - Filtered Items

    var filteredItems: [WardrobeItem] {
        //    print("filteredItems — occasion filter:", itemFilters["03-occasion"] ?? "none") // debugging print
            var result = items

        // Sort
        if let sort = itemFilters["01-sort by"] {
            switch sort {
            case "A–Z":
                result = result.sorted { ($0.name) < ($1.name) }
            case "Brand":
                result = result.sorted { ($0.brand ?? "") < ($1.brand ?? "") }
            default:
                break // "Recently added" — preserve fetch order
            }
        }

        // Status
        if let status = itemFilters["02-status"], status != "All" {
            switch status {
            case "Worn":   result = result.filter { (wornCounts[$0.id] ?? 0) > 0 }
            case "Unworn": result = result.filter { (wornCounts[$0.id] ?? 0) == 0 }
            default:       break
            }
        }

        // Occasion
        if let occasion = itemFilters["03-occasion"], occasion != "All" {
            result = result.filter {
                $0.occasion?.caseInsensitiveCompare(occasion) == .orderedSame
            }
        }

        return result
    }

    // MARK: - Filtered Outfits

    var filteredOutfits: [WardrobeOutfit] {
        var result = outfits

        // Sort
        if let sort = outfitFilters["01-sort by"] {
            switch sort {
            case "Date":
                result = result.sorted { $0.id.uuidString < $1.id.uuidString }
            default:
                break // "Recently saved" — preserve fetch order
            }
        }

        // Occasion
        if let occasion = outfitFilters["02-occasion"], occasion != "All" {
            result = result.filter {
                $0.occasion?.caseInsensitiveCompare(occasion) == .orderedSame
            }
        }

        return result
    }
}
