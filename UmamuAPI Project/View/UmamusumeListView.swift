import SwiftUI

struct UmamusumeListView: View {

    @State private var list: [Umamusume] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Cargando umamusumes...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List(list, id: \.id) { u in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(u.name)
                                .font(.headline)

                            Text("Sparks: \(u.sparks.map(String.init).joined(separator: ", "))")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            Text("Insp 1: \(u.inspirationID1) • Insp 2: \(u.inspirationID2)")
                                .font(.caption)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("🐴 Umamusume")
        }
        .onAppear {
            loadUmamusumes()
        }
    }

    private func loadUmamusumes() {
        APIService.fetchUmamusumes(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json"
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.list = list
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
