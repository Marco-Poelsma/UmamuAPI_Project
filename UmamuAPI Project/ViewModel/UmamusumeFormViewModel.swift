import Foundation

class UmamusumeFormViewModel: ObservableObject {

    enum Mode {
        case create
        case edit
        case view
    }

    @Published var name: String = ""
    @Published var selectedSparks: [Umamusume.UmamusumeSpark] = []
    @Published var inspirationID1: Int?
    @Published var inspirationID2: Int?

    @Published var mode: Mode = .create
    @Published var isReadOnly: Bool = false

    @Published var umamusumeAll: [Umamusume] = []
    @Published var sparkAll: [Spark] = []

    // 🔥 NUEVO: guardar estado original del favorito
    private var originalIsFavourite: Bool = false

    var inspirationsCompact: [Umamusume] {
        var list: [Umamusume] = []
        if let i1 = inspiration1 { list.append(i1) }
        if let i2 = inspiration2 { list.append(i2) }
        return list
    }

    var inspiration1: Umamusume? {
        umamusumeAll.first(where: { $0.id == inspirationID1 })
    }

    var inspiration2: Umamusume? {
        umamusumeAll.first(where: { $0.id == inspirationID2 })
    }

    var sparkByID: [Int: Spark] {
        Dictionary(uniqueKeysWithValues: sparkAll.map { ($0.id, $0) })
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        inspirationID1 != nil &&
        inspirationID2 != nil
    }

    var existingID: Int?

    init(mode: Mode = .create, umamusume: Umamusume? = nil) {
        self.mode = mode
        self.isReadOnly = (mode == .view)

        if let u = umamusume {
            self.existingID = u.id
            self.name = u.name
            self.selectedSparks = u.sparks
            self.inspirationID1 = u.inspirationID1
            self.inspirationID2 = u.inspirationID2

            // 🔥 IMPORTANTE: guardar el favorito original
            self.originalIsFavourite = u.isFavourite
        }
    }

    func loadData() {
        loadUmamusumes()
        loadSparks()
    }

    private func loadUmamusumes() {
        APIService.fetchUmamusumes(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json"
        ) { result in
            if case let .success(data) = result {
                DispatchQueue.main.async {
                    self.umamusumeAll = data
                }
            }
        }
    }

    private func loadSparks() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in
            if case let .success(data) = result {
                DispatchQueue.main.async {
                    self.sparkAll = data
                }
            }
        }
    }

    func setInspirations(from ids: Set<Int>) {
        let selected = umamusumeAll.filter { ids.contains($0.id) }
        inspirationID1 = selected.first?.id
        inspirationID2 = selected.dropFirst().first?.id
    }

    func toUmamusume() -> Umamusume {
        let newId = existingID ?? ((umamusumeAll.map { $0.id }.max() ?? 0) + 1)

        return Umamusume(
            id: newId,
            name: name,
            sparks: selectedSparks,
            inspirationID1: inspirationID1 ?? 0,
            inspirationID2: inspirationID2 ?? 0,
            isFavourite: originalIsFavourite // 👈 mantiene el estado original
        )
    }
}
