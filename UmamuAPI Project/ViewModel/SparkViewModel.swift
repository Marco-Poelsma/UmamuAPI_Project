import Foundation

class SparkViewModel {

    var sparks: [Spark] = []

    func loadSparks() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in

            switch result {
            case .success(let sparks):
                self.sparks = sparks
                print("Sparks loaded:", sparks)

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
