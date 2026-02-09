import SwiftUI

struct SparkPickerSheet: View {

    @Environment(\.presentationMode) private var presentationMode
    @State private var sparks: [Spark] = []

    let onSelect: (Umamusume.UmamusumeSpark) -> Void

    var body: some View {
        NavigationView {
            List(sparks) { spark in
                Button(action: {
                    onSelect(
                        Umamusume.UmamusumeSpark(
                            spark: spark.id,
                            rarity: 1
                        )
                    )
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(spark.name)
                        Text(spark.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitle("Select Spark")
        }
        .onAppear(perform: load)
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
