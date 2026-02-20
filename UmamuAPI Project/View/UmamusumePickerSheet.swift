import SwiftUI

struct UmamusumePickerSheet: View {
    // MARK: - Environment
    @Environment(\.presentationMode) private var presentationMode
    
    // MARK: - ViewModel
    @ObservedObject var viewModel: UmamusumePickerViewModel
    
    // MARK: - Body
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
        .navigationBarItems(leading: cancelButton, trailing: saveButton)
        .alert(isPresented: $viewModel.showValidationAlert) { validationAlert }
        .onAppear(perform: configureTableViewAppearance)
    }
    
    // MARK: - Navigation Buttons
    private var cancelButton: some View {
        Button("Cancel") {
            viewModel.cancel()
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var saveButton: some View {
        Button("Save") {
            if viewModel.validateAndSave() {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var validationAlert: Alert {
        Alert(
            title: Text("Selección inválida"),
            message: Text(viewModel.validationMessage),
            dismissButton: .default(Text("OK"))
        )
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Buscar umamusume...", text: $viewModel.searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button(action: viewModel.clearSearch) {
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
    
    // MARK: - Content List
    private var contentList: some View {
        VStack(spacing: 0) {
            List {
                sectionHeader
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                
                ForEach(Array(viewModel.filteredItems.enumerated()), id: \.element.id) { index, item in
                    UmamusumeRowView(
                        item: item,
                        index: index,
                        totalItems: viewModel.filteredItems.count,
                        isSelected: viewModel.isSelected(item.id),
                        onTap: {
                            viewModel.toggleSelection(item.id)
                        }
                    )
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
    
    // MARK: - Section Header
    private var sectionHeader: some View {
        HStack {
            Text("UMAMUSUME")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(viewModel.filteredItems.count) items")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("(\(viewModel.selectedCount)/2)")
                .font(.caption)
                .foregroundColor(viewModel.selectionStatusColor)
                .padding(.leading, 4)
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color.white)
    }
    
    // MARK: - Helpers
    private func configureTableViewAppearance() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
}

// MARK: - Umamusume Row View (con el estilo original)
struct UmamusumeRowView: View {
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
                        .foregroundColor(.secondary)
                        .frame(width: 40, alignment: .leading)
                    
                    Text(item.name)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if item.isFavourite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
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
            
            if index < totalItems - 1 {
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 16)
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(index == 0 ? 12 : 0, corners: [.topLeft, .topRight])
        .cornerRadius(index == totalItems - 1 ? 12 : 0, corners: [.bottomLeft, .bottomRight])
    }
}
