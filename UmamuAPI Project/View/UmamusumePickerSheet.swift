import SwiftUI
import Combine

struct UmamusumePickerSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: UmamusumePickerViewModel
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBar
                contentList
            }
        }
        .navigationBarTitle("Select Inspirations", displayMode: .inline)
        .navigationBarItems(leading: cancelButton, trailing: saveButton)
        .alert(isPresented: $viewModel.showValidationAlert) { validationAlert }
        .onAppear {
            configureTableViewAppearance()
            viewModel.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UmamusumesUpdated"))) { notification in
            // Cuando llegue la notificación, actualizar la vista
            if let newItems = notification.object as? [Umamusume] {
                print("📬 Picker recibió notificación de actualización: \(newItems.count) items")
                // Forzar refresco de la UI
                viewModel.objectWillChange.send()
                viewModel.refreshID = UUID()
            }
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") {
            viewModel.cancel()
            presentationMode.wrappedValue.dismiss()
        }
        .foregroundColor(.appBlue)
    }
    
    private var saveButton: some View {
        Button("Save") {
            if viewModel.validateAndSave() {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .foregroundColor(.appBlue)
        .disabled(viewModel.selectedIDs.count > 2) // Opcional: deshabilitar si más de 2 seleccionados
    }
    
    private var validationAlert: Alert {
        Alert(
            title: Text("Selección inválida"),
            message: Text(viewModel.validationMessage),
            dismissButton: .default(Text("OK"))
        )
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.searchBarIcon)
            
            TextField("Buscar umamusume...", text: $viewModel.searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(.searchBarText)
            
            if !viewModel.searchText.isEmpty {
                Button(action: viewModel.clearSearch) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.searchBarClearButton)
                }
            }
        }
        .padding(10)
        .background(Color.searchBarBackground)
        .cornerRadius(20)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
    
    private var contentList: some View {
        VStack(spacing: 0) {
            List {
                sectionHeader
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                
                ForEach(Array(viewModel.filteredItems.enumerated()), id: \.element.id) { index, item in
                    PickerRowView(
                        item: item,
                        index: index,
                        totalItems: viewModel.filteredItems.count,
                        isSelected: viewModel.selectedIDs.contains(item.id),
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.toggleSelection(item.id)
                            }
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .environment(\.defaultMinListRowHeight, 0)
            .id(viewModel.refreshID) // IMPORTANTE: Forzar refresco cuando cambia refreshID
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }
    
    private var sectionHeader: some View {
        HStack {
            Text("UMAMUSUME")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Spacer()
            
            Text("\(viewModel.filteredItems.count) items")
                .font(.subheadline)
                .foregroundColor(.secondaryText)
            
            Text("(\(viewModel.selectedIDs.count)/2)")
                .font(.caption)
                .foregroundColor(viewModel.selectionStatusColor)
                .padding(.leading, 4)
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color.appBackground)
    }
    
    private func configureTableViewAppearance() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
}

// MARK: - Picker Row View
struct PickerRowView: View {
    let item: Umamusume
    let index: Int
    let totalItems: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text("\(item.id)")
                        .font(.headline)
                        .foregroundColor(.secondaryText)
                        .frame(width: 40, alignment: .leading)
                    
                    Text(item.name)
                        .font(.body)
                        .foregroundColor(.primaryText)
                    
                    Spacer()
                    
                    if item.isFavourite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.appPink)
                            .padding(.trailing, 8)
                    } else {
                        Image(systemName: "star")
                            .font(.system(size: 14))
                            .foregroundColor(.clear)
                            .padding(.trailing, 8)
                    }
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.appBlue)
                            .clipShape(Circle())
                            .font(.system(size: 10, weight: .bold))
                    }
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .background(isSelected ? Color.appBlue.opacity(0.1) : Color.clear) // Feedback visual al seleccionar
            }
            .buttonStyle(PlainButtonStyle())
            
            if index < totalItems - 1 {
                Divider()
                    .background(Color.lightGray)
                    .padding(.leading, 16)
            }
        }
        .background(Color.primaryFill)
        .cornerRadius(index == 0 ? 12 : 0, corners: [.topLeft, .topRight])
        .cornerRadius(index == totalItems - 1 ? 12 : 0, corners: [.bottomLeft, .bottomRight])
        .animation(.easeInOut(duration: 0.2), value: isSelected) // Animación al cambiar selección
    }
}
