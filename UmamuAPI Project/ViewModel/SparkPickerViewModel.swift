import SwiftUI
import Combine

class SparkPickerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var sparks: [Spark] = []
    @Published var searchText = ""
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    
    // MARK: - Binding
    var selectedIDs: Binding<Set<Int>>
    private var selectedIDsValue: Set<Int> {
        didSet {
            selectedIDs.wrappedValue = selectedIDsValue
        }
    }
    
    // MARK: - Dependencies
    private let onSave: () -> Void
    private let onCancel: () -> Void
    
    // MARK: - Init
    init(selectedIDs: Binding<Set<Int>>,
         onSave: @escaping () -> Void,
         onCancel: @escaping () -> Void) {
        self.selectedIDs = selectedIDs
        self.selectedIDsValue = selectedIDs.wrappedValue
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    // MARK: - Computed Properties
    var filteredSparks: [Spark] {
        if searchText.isEmpty {
            return sparks
        } else {
            return sparks.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var statSparks: [Spark] {
        filteredSparks.filter { $0.type == .stat }
    }
    
    var aptitudeSparks: [Spark] {
        filteredSparks.filter { $0.type == .aptitude }
    }
    
    var skillSparks: [Spark] {
        filteredSparks.filter { $0.type == .skill }
    }
    
    var uniqueSkillSparks: [Spark] {
        filteredSparks.filter { $0.type == .uniqueSkill }
    }
    
    var selectedStats: [Spark] {
        sparks.filter { selectedIDsValue.contains($0.id) && $0.type == .stat }
    }
    
    var selectedAptitudes: [Spark] {
        sparks.filter { selectedIDsValue.contains($0.id) && $0.type == .aptitude }
    }
    
    var selectedUniqueSkills: [Spark] {
        sparks.filter { selectedIDsValue.contains($0.id) && $0.type == .uniqueSkill }
    }
    
    var isSelectionValid: Bool {
        guard selectedStats.count == 1 else {
            validationMessage = "Debes seleccionar exactamente 1 spark de Stat"
            return false
        }
        
        guard selectedAptitudes.count == 1 else {
            validationMessage = "Debes seleccionar exactamente 1 spark de Aptitude"
            return false
        }
        
        guard selectedUniqueSkills.count >= 0 && selectedUniqueSkills.count <= 3 else {
            validationMessage = "Debes seleccionar entre 0 y 3 sparks de Unique Skill"
            return false
        }
        
        return true
    }
    
    var statSelectionColor: Color {
        selectedStats.count == 1 ? .green : .red
    }
    
    var aptitudeSelectionColor: Color {
        selectedAptitudes.count == 1 ? .green : .red
    }
    
    var uniqueSelectionColor: Color {
        selectedUniqueSkills.count <= 3 ? .green : .red
    }
    
    // MARK: - Public Methods
    func toggleSelection(_ id: Int) {
        if selectedIDsValue.contains(id) {
            selectedIDsValue.remove(id)
        } else {
            selectedIDsValue.insert(id)
        }
    }
    
    func isSelected(_ id: Int) -> Bool {
        selectedIDsValue.contains(id)
    }
    
    func validateAndSave() -> Bool {
        if isSelectionValid {
            onSave()
            return true
        } else {
            showValidationAlert = true
            return false
        }
    }
    
    func cancel() {
        onCancel()
    }
    
    func clearSearch() {
        searchText = ""
    }
    
    func loadSparks() {
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
