import SwiftUI

struct AddItemView: View {
    let onSave: (String, String, String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var category = ""
    @State private var productCode = ""
    @State private var colorNote = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Item") {
                    TextField("Title", text: $title)
                    TextField("Category", text: $category)
                    TextField("Product Code", text: $productCode)
                    TextField("Color Note", text: $colorNote)
                }

                Section("Photo") {
                    Label("Camera and gallery intake land here next.", systemImage: "camera")
                        .foregroundStyle(ArenColor.Text.secondary)
                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(title, category, productCode, colorNote)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || productCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
