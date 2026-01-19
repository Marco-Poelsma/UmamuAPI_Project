import SwiftUI

struct SparkListView: View {

    @State private var sparks: [Spark] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Cargando sparks...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(sparks, id: \.id) { spark in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(spark.name)
                                    .font(.headline)

                                Spacer()

                                Text(spark.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Text(spark.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("✨ Sparks")
        }
        .onAppear {
            loadSparks()
        }
    }

    private func loadSparks() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sparks):
                    self.sparks = sparks
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
