import SwiftUI

struct UmamusumePickerSheet: View {

    @Environment(\.presentationMode) private var presentationMode

    let items: [Umamusume]
    @Binding var selectedIDs: Set<Int>

    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        List(items) { u in
            Button(action: {
                toggleSelection(u.id)
            }) {
                HStack {
                    Text(u.name)
                    Spacer()
                    if selectedIDs.contains(u.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            .listRowBackground(selectedIDs.contains(u.id) ? Color.blue.opacity(0.2) : Color.clear)
        }
        .navigationBarTitle("Select Inspirations")
        .navigationBarItems(
            leading: Button("Cancel") {
                onCancel()
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                onSave()
                presentationMode.wrappedValue.dismiss()
            }
        )
    }

    private func toggleSelection(_ id: Int) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            if selectedIDs.count < 2 {
                selectedIDs.insert(id)
            }
        }
    }
}
