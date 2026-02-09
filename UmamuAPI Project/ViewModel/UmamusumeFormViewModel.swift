import Foundation
import Combine

final class UmamusumeFormViewModel: ObservableObject {

    @Published var name: String = ""
    @Published var selectedSparks: [Umamusume.UmamusumeSpark] = []
    @Published var inspiration1: Umamusume?
    @Published var inspiration2: Umamusume?

    let mode: UmamusumeFormMode
    let original: Umamusume?

    init(mode: UmamusumeFormMode, umamusume: Umamusume? = nil) {
        self.mode = mode
        self.original = umamusume

        if let u = umamusume {
            self.name = u.name
            self.selectedSparks = u.sparks
        }
    }

    var isReadOnly: Bool {
        mode == .view
    }

    var canSave: Bool {
        !isReadOnly &&
        !name.isEmpty &&
        inspiration1 != nil &&
        inspiration2 != nil &&
        !selectedSparks.isEmpty
    }
}
