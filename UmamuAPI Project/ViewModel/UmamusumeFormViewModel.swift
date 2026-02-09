import Foundation

class UmamusumeFormViewModel: ObservableObject {

    enum Mode {
        case create
        case edit
        case view
    }

    @Published var name: String = ""
    @Published var selectedSparks: [Umamusume.UmamusumeSpark] = []
    @Published var inspiration1: Umamusume?
    @Published var inspiration2: Umamusume?

    @Published var mode: Mode = .create
    @Published var isReadOnly: Bool = false

    @Published var umamusumeAll: [Umamusume] = []
    @Published var sparkAll: [Spark] = []

    var inspirationsCompact: [Umamusume] {
        var list: [Umamusume] = []
        if let i1 = inspiration1 { list.append(i1) }
        if let i2 = inspiration2 { list.append(i2) }
        return list
    }

    var sparkByID: [Int: Spark] {
        Dictionary(uniqueKeysWithValues: sparkAll.map { ($0.id, $0) })
    }

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(mode: Mode = .create) {
        self.mode = mode
        self.isReadOnly = (mode == .view)
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
        inspiration1 = selected.first
        inspiration2 = selected.dropFirst().first
    }
}
