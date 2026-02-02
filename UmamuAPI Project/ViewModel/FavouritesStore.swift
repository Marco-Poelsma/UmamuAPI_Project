import Foundation

final class FavouritesStore {

    static let shared = FavouritesStore()
    private let key = "favourite_umamusumes"

    private init() {}

    func load() -> Set<Int> {
        let array = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
        return Set(array)
    }

    func save(_ favourites: Set<Int>) {
        UserDefaults.standard.set(Array(favourites), forKey: key)
    }

    func toggle(id: Int) {
        var favs = load()
        if favs.contains(id) {
            favs.remove(id)
        } else {
            favs.insert(id)
        }
        save(favs)
    }

    func isFavourite(id: Int) -> Bool {
        load().contains(id)
    }
}
