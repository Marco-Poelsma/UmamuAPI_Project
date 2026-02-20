import Foundation
import SwiftUI
import Combine

class UmamusumePickerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var items: [Umamusume]
    @Published var selectedIDs: Set<Int>
    @Published var searchText = ""
    @Published var showValidationAlert = false
    @Published var validationMessage = ""
    @Published var refreshID = UUID()
    
    // MARK: - Private Properties
    private let maxSelections = 2
    private let onSave: (Set<Int>) -> Void
    private let onCancel: () -> Void
    private var cancellables = Set<AnyCancellable>()
    private var snapshotID = UUID().uuidString
    
    // MARK: - Initialization
    init(items: [Umamusume],
         selectedIDs: Binding<Set<Int>>,
         onSave: @escaping (Set<Int>) -> Void,
         onCancel: @escaping () -> Void) {
        
        self.items = items
        self._selectedIDs = Published(initialValue: selectedIDs.wrappedValue)
        self.onSave = onSave
        self.onCancel = onCancel
        
        print("📋 PickerViewModel creado con ID: \(snapshotID.prefix(8)) - \(items.count) items")
        
        setupSearchObserver()
    }
    
    // MARK: - Computed Properties
    var filteredItems: [Umamusume] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                String($0.id).contains(searchText)
            }
        }
    }
    
    var selectedCount: Int {
        selectedIDs.count
    }
    
    var selectionStatusColor: Color {
        switch selectedIDs.count {
        case 2: return .green
        case 1: return .orange
        default: return .secondary
        }
    }
    
    // MARK: - Methods
    func loadData() {
        // Ya no necesitamos cargar datos, vienen de la caché
        objectWillChange.send()
        refreshID = UUID()
    }
    
    func toggleSelection(_ id: Int) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else if selectedIDs.count < maxSelections {
            selectedIDs.insert(id)
        } else {
            showValidationAlert = true
            validationMessage = "Solo puedes seleccionar hasta \(maxSelections) umamusumes."
            return
        }
        
        objectWillChange.send()
        refreshID = UUID()
        
        print("✅ [\(snapshotID.prefix(8))] Selección actualizada: \(selectedIDs.count) items")
    }
    
    func isSelected(_ id: Int) -> Bool {
        selectedIDs.contains(id)
    }
    
    func validateAndSave() -> Bool {
        if selectedIDs.isEmpty {
            validationMessage = "Debes seleccionar al menos un umamusume."
            showValidationAlert = true
            return false
        }
        
        if selectedIDs.count > maxSelections {
            validationMessage = "No puedes seleccionar más de \(maxSelections) umamusumes."
            showValidationAlert = true
            return false
        }
        
        onSave(selectedIDs)
        return true
    }
    
    func cancel() {
        onCancel()
    }
    
    func clearSearch() {
        searchText = ""
        objectWillChange.send()
        refreshID = UUID()
    }
    
    // MARK: - Private Methods
    private func setupSearchObserver() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.refreshID = UUID()
            }
            .store(in: &cancellables)
    }
}
