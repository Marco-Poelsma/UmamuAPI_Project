import SwiftUI

struct UmamusumePickerSheet: View {

    @Environment(\.presentationMode) private var presentationMode

    let items: [Umamusume]
    @Binding var selectedIDs: Set<Int>

    let onSave: () -> Void
    let onCancel: () -> Void
    
    @State private var searchText = ""

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
                onSave()
                presentationMode.wrappedValue.dismiss()
            }
        )
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
                // 🔥 HEADER COMO PARTE DEL CONTENIDO (no como header de sección)
                sectionHeader
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                
                // 🔥 FILTRADOS
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
            
            // Indicador de selección
            Text("(\(selectedIDs.count)/2)")
                .font(.caption)
                .foregroundColor(selectedIDs.count <= 2 ? .green : .red)
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
            // Botón que ocupa toda el área
            Button(action: {
                toggleSelection(item.id)
            }) {
                HStack {
                    Text(item.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
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
            
            // Divider solo entre elementos
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
