import SwiftUI

struct OutfitZoneView: View {
    let rows: [SwipeRowState]
    let onSelectionChanged: (SwipeRowState.ID, Int) -> Void

    var body: some View {
        VStack(spacing: ArenSpacing.xl) {
            ForEach(rows) { row in
                SwipeRow(row: row) { index in
                    onSelectionChanged(row.id, index)
                }
            }
        }
    }
}
