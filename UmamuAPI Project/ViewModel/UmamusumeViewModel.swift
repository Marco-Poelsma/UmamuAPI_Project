import Foundation

class UmamusumeViewModel: ObservableObject {

    @Published var umamusumes: [Umamusume] = []
    @Published var sparks: [Spark] = []

    // MARK: - Lookups
    var sparkByID: [Int: Spark] {
        Dictionary(uniqueKeysWithValues: sparks.map { ($0.id, $0) })
    }

    var umamusumeByID: [Int: Umamusume] {
        Dictionary(uniqueKeysWithValues: umamusumes.map { ($0.id, $0) })
    }

    func loadData() {
        loadUmamusumes()
        loadSparks()
    }

    private func loadUmamusumes() {
        APIService.fetchUmamusumes(urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json") { result in
            if case let .success(data) = result {
                self.umamusumes = data
            }
        }
    }

    private func loadSparks() {
        APIService.fetchSparks(urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json") { result in
            if case let .success(data) = result {
                self.sparks = data
            }
        }
    }
}
