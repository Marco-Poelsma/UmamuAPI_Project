import SwiftUI

struct UmamusumePickerSheet: View {

    @Environment(\.presentationMode) private var presentationMode

    let items: [Umamusume]
    @Binding var selectedIDs: Set<Int>

    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var searchText = ""
    @State private var showValidationAlert = false
    @State private var validationMessage = ""

    // MARK: - Filtering
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
    
    // MARK: - Validation
    private var isValid: Bool {
        guard selectedIDs.count == 2 else {
            validationMessage = "Debes seleccionar exactamente 2 umamusume"
            return false
        }
        return true
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBar
                contentList
            }
        }
        .navigationBarTitle("Select Inspirations", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Cancel") {
                onCancel()
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("Save") {
                if isValid {
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                } else {
                    showValidationAlert = true
                }
            }
        )
        .alert(isPresented: $showValidationAlert) {
            Alert(
                title: Text("Selección inválida"),
                message: Text(validationMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableViewHeaderFooterView.appearance().tintColor = .clear
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().separatorColor = .clear
            UITableView.appearance().tableFooterView = UIView()
        }
    }
    
    // MARK: - Subviews
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar umamusume...", text: $searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !searchText.isEmpty {
                Button(action: { searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
    
    private var contentList: some View {
        VStack(spacing: 0) {
            List {
                // Header como parte del contenido
                sectionHeader
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                
                // Filas filtradas
                ForEach(Array(filteredItems.enumerated()), id: \.element.id) { index, item in
                    umamusumeRow(item: item, index: index, category: filteredItems)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .environment(\.defaultMinListRowHeight, 0)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("UMAMUSUME")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(filteredItems.count) items")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Indicador de selección con color
            Text("(\(selectedIDs.count)/2)")
                .font(.caption)
                .foregroundColor(selectedIDs.count == 2 ? .green : .red)
                .padding(.leading, 4)
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color.white)
    }
    
    // MARK: - Umamusume Row
    private func umamusumeRow(item: Umamusume, index: Int, category: [Umamusume]) -> some View {
        VStack(spacing: 0) {
            Button(action: {
                toggleSelection(item.id)
            }) {
                HStack {
                    // ID
                    Text("\(item.id)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .leading)
                    
                    // Nombre
                    Text(item.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Estrella de favorito (solo visual, NO es botón)
                    if item.isFavourite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
                    } else {
                        Image(systemName: "star")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .padding(.trailing, 8)
                    }
                    
                    // Checkmark de selección
                    if selectedIDs.contains(item.id) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .font(.system(size: 10, weight: .bold))
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if index < category.count - 1 {
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 16)
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(
            index == 0 ? 12 : 0,
            corners: [.topLeft, .topRight]
        )
        .cornerRadius(
            index == category.count - 1 ? 12 : 0,
            corners: [.bottomLeft, .bottomRight]
        )
    }

    // MARK: - Selection
    private func toggleSelection(_ id: Int) {
        if selectedIDs.contains(id) {
            selectedIDs.remove(id)
        } else {
            if selectedIDs.count < 2 {
                selectedIDs.insert(id)
            }
        }
    }
}
