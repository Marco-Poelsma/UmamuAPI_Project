import SwiftUI

struct SparkPickerSheet: View {

    @Environment(\.presentationMode) private var presentationMode

    @State private var sparks: [Spark] = []
    @Binding var selectedIDs: Set<Int>

    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationView {
            List(sparks) { spark in
                Button(action: {
                    toggleSelection(spark.id)
                }) {
                    HStack {
                        Text(spark.name)
                        Spacer()
                        if selectedIDs.contains(spark.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    }
                }
                .listRowBackground(selectedIDs.contains(spark.id) ? Color.blue.opacity(0.2) : Color.clear)
            }
            .navigationBarTitle("Select Sparks")
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
        .onAppear(perform: load)
    }

    private func toggleSelection(_ id: Int) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            selectedIDs.insert(id)
        }
    }

    private func load() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in
            if case let .success(data) = result {
                DispatchQueue.main.async {
                    sparks = data
                }
            }
        }
    }
}
