import SwiftUI

struct WardrobeScreen: View {
    @StateObject private var viewModel = WardrobeViewModel()
    @State private var isPresentingAddItem = false

    var body: some View {
        NavigationStack {
            List(viewModel.items) { item in
                VStack(alignment: .leading, spacing: ArenSpacing.xs) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(ArenColor.Text.primary)

                    Text("\(item.category) · \(item.productCode)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(ArenColor.Text.secondary)

                    Text(item.colorNote)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(ArenColor.Text.tertiary)
                }
                .padding(.vertical, ArenSpacing.xs)
            }
            .listStyle(.plain)
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingAddItem = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddItem) {
                AddItemView { title, category, productCode, colorNote in
                    viewModel.addItem(title: title, category: category, productCode: productCode, colorNote: colorNote)
                }
            }
        }
    }
}

#Preview {
    WardrobeScreen()
}
