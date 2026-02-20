import SwiftUI
import Combine

class UmamusumePickerViewModel: ObservableObject {
    // MARK: - Published Properties
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
        selectedIDsValue.count
    }
    
    var isSelectionValid: Bool {
        selectedIDsValue.count == 2
    }
    
    var selectionStatusColor: Color {
        isSelectionValid ? .green : .red
    }
    
    // MARK: - Init
    init(items: [Umamusume],
         selectedIDs: Binding<Set<Int>>,
         onSave: @escaping () -> Void,
         onCancel: @escaping () -> Void) {
        self.items = items
        self.selectedIDs = selectedIDs
        self.selectedIDsValue = selectedIDs.wrappedValue
        self.onSave = onSave
        self.onCancel = onCancel
    }
    
    // MARK: - Public Methods
    func toggleSelection(_ id: Int) {
        if selectedIDsValue.contains(id) {
            selectedIDsValue.remove(id)
        } else if selectedIDsValue.count < 2 {
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
