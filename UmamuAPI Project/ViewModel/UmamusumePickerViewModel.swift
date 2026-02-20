import SwiftUI
import Combine

class UmamusumePickerViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText = ""
    @Published var selectedIDs: Set<Int>
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    
    // MARK: - Dependencies
    private let items: [Umamusume]
    private let onSave: () -> Void
    private let onCancel: () -> Void
    
    // MARK: - Computed Properties
    var filteredItems: [Umamusume] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { item in
                let nameMatch = item.name.lowercased().contains(searchText.lowercased())
                let idMatch = String(item.id).contains(searchText)
                return nameMatch || idMatch
            }
        }
    }
    
    var selectedCount: Int {
        selectedIDs.count
    }
    
    var isSelectionValid: Bool {
        selectedIDs.count == 2
    }
    
    var selectionStatusColor: Color {
        isSelectionValid ? .green : .red
    }
    
    // MARK: - Init
    init(items: [Umamusume],
         selectedIDs: Set<Int>,
         onSave: @escaping () -> Void,
         onCancel: @escaping () -> Void) {
        self.items = items
        self.selectedIDs = selectedIDs
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    // MARK: - Public Methods
    func toggleSelection(_ id: Int) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else if selectedIDs.count < 2 {
            selectedIDs.insert(id)
        }
    }
    
    func isSelected(_ id: Int) -> Bool {
        selectedIDs.contains(id)
    }
    
    func validateAndSave() -> Bool {
        if isSelectionValid {
            onSave()
            return true
        } else {
            validationMessage = "Debes seleccionar exactamente 2 umamusume"
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
}
