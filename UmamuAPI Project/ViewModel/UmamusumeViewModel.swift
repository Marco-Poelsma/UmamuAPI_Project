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

    // MARK: - Public

    func loadData() {
        loadUmamusumes()
        loadSparks()
    }

    func toggleFavourite(for id: Int) {
        guard let index = umamusumes.firstIndex(where: { $0.id == id }) else { return }

        umamusumes[index].isFavourite.toggle()
        FavouritesStore.shared.toggle(id: id)
    }

    // MARK: - Private

    private func loadUmamusumes() {
        APIService.fetchUmamusumes(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json"
        ) { result in
            if case let .success(data) = result {

                let favourites = FavouritesStore.shared.load()

                let mapped = data.map { u -> Umamusume in
                    var copy = u
                    copy.isFavourite = favourites.contains(u.id)
                    return copy
                }

                let sorted = self.sortUmamusumes(mapped)

                DispatchQueue.main.async {
                    self.umamusumes = sorted
                }
            }
        }
    }
    
    func delete(ids: [Int]) {
        guard umamusumes.count - ids.count >= 3 else { return }

        umamusumes.removeAll { ids.contains($0.id) }

        var favourites = FavouritesStore.shared.load()
        ids.forEach { favourites.remove($0) }
        FavouritesStore.shared.save(favourites)

    }




    
    private func sortUmamusumes(_ list: [Umamusume]) -> [Umamusume] {
        list.sorted {
            if $0.isFavourite != $1.isFavourite {
                return $0.isFavourite && !$1.isFavourite
            }
            return $0.id < $1.id
        }
    }


    private func loadSparks() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in
            if case let .success(data) = result {
                DispatchQueue.main.async {
                    self.sparks = data
                }
            }
        }
    }
}
