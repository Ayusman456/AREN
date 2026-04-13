import Foundation
import Supabase
import Combine

@MainActor
final class WardrobeViewModel: ObservableObject {
    @Published var items: [WardrobeItem] = []
    @Published var outfits: [WardrobeOutfit] = []
    @Published var isLoading: Bool = false
    @Published var error: String? = nil

    private let client = SupabaseService.shared.client

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
        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }
}
