import SwiftUI

struct SparkPickerSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: SparkPickerViewModel
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBar
                contentList
            }
        }
        .navigationBarTitle("Select Sparks", displayMode: .inline)
        .navigationBarItems(leading: cancelButton, trailing: saveButton)
        .alert(isPresented: $viewModel.showValidationAlert) { validationAlert }
        .onAppear(perform: onAppear)
    }
    
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
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Buscar spark...", text: $viewModel.searchText)
                .autocapitalization(.none).disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button(action: viewModel.clearSearch) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20)
        .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 4)
    }
    
    private var contentList: some View {
        VStack(spacing: 0) {
            List {
                if !viewModel.statSparks.isEmpty {
                    StatSectionView(viewModel: viewModel)
                        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
                }
                
                if !viewModel.aptitudeSparks.isEmpty {
                    AptitudeSectionView(viewModel: viewModel)
                        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
                }
                
                if !viewModel.skillSparks.isEmpty {
                    SkillSectionView(viewModel: viewModel)
                        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
                }
                
                if !viewModel.uniqueSkillSparks.isEmpty {
                    UniqueSkillSectionView(viewModel: viewModel)
                        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .environment(\.defaultMinListRowHeight, 0)
        }
        .padding(.horizontal, 16).padding(.bottom, 16)
    }
    
    private func onAppear() {
        viewModel.loadSparks()
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
}

// MARK: - Section Views
struct StatSectionView: View {
    @ObservedObject var viewModel: SparkPickerViewModel
    
    var body: some View {
        Section(header: sectionHeader(
            title: "STAT",
            count: viewModel.statSparks.count,
            selectionText: "(\(viewModel.selectedStats.count)/1)",
            selectionColor: viewModel.statSelectionColor
        )) {
            ForEach(Array(viewModel.statSparks.enumerated()), id: \.element.id) { index, spark in
                SparkPickerRowView(
                    spark: spark,
                    index: index,
                    totalItems: viewModel.statSparks.count,
                    isSelected: viewModel.isSelected(spark.id),
                    onTap: {
                        viewModel.toggleSelection(spark.id)
                    }
                )
                .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            }
        }
    }
}

struct AptitudeSectionView: View {
    @ObservedObject var viewModel: SparkPickerViewModel
    
    var body: some View {
        Section(header: sectionHeader(
            title: "APTITUDE",
            count: viewModel.aptitudeSparks.count,
            selectionText: "(\(viewModel.selectedAptitudes.count)/1)",
            selectionColor: viewModel.aptitudeSelectionColor
        )) {
            ForEach(Array(viewModel.aptitudeSparks.enumerated()), id: \.element.id) { index, spark in
                SparkPickerRowView(
                    spark: spark,
                    index: index,
                    totalItems: viewModel.aptitudeSparks.count,
                    isSelected: viewModel.isSelected(spark.id),
                    onTap: {
                        viewModel.toggleSelection(spark.id)
                    }
                )
                .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            }
        }
    }
}

struct SkillSectionView: View {
    @ObservedObject var viewModel: SparkPickerViewModel
    
    var body: some View {
        Section(header: simpleHeader(title: "SKILL", count: viewModel.skillSparks.count)) {
            ForEach(Array(viewModel.skillSparks.enumerated()), id: \.element.id) { index, spark in
                SparkPickerRowView(
                    spark: spark,
                    index: index,
                    totalItems: viewModel.skillSparks.count,
                    isSelected: viewModel.isSelected(spark.id),
                    onTap: {
                        viewModel.toggleSelection(spark.id)
                    }
                )
                .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            }
        }
    }
}

struct UniqueSkillSectionView: View {
    @ObservedObject var viewModel: SparkPickerViewModel
    
    var body: some View {
        Section(header: sectionHeader(
            title: "UNIQUE",
            count: viewModel.uniqueSkillSparks.count,
            selectionText: "(\(viewModel.selectedUniqueSkills.count)/3)",
            selectionColor: viewModel.uniqueSelectionColor
        )) {
            ForEach(Array(viewModel.uniqueSkillSparks.enumerated()), id: \.element.id) { index, spark in
                SparkPickerRowView(
                    spark: spark,
                    index: index,
                    totalItems: viewModel.uniqueSkillSparks.count,
                    isSelected: viewModel.isSelected(spark.id),
                    onTap: {
                        viewModel.toggleSelection(spark.id)
                    }
                )
                .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            }
        }
    }
}

// MARK: - Header Helpers
private func sectionHeader(title: String, count: Int, selectionText: String, selectionColor: Color) -> some View {
    HStack {
        Text(title).font(.title3).fontWeight(.bold).foregroundColor(.primary)
        Spacer()
        Text("\(count) sparks").font(.subheadline).foregroundColor(.secondary)
        Text(selectionText).font(.caption).foregroundColor(selectionColor).padding(.leading, 4)
    }
    .padding(.horizontal, 4).padding(.top, 8).padding(.bottom, 4)
    .background(Color.white)
}

private func simpleHeader(title: String, count: Int) -> some View {
    HStack {
        Text(title).font(.title3).fontWeight(.bold).foregroundColor(.primary)
        Spacer()
        Text("\(count) sparks").font(.subheadline).foregroundColor(.secondary)
    }
    .padding(.horizontal, 4).padding(.top, 8).padding(.bottom, 4)
    .background(Color.white)
}

// MARK: - Spark Picker Row View
struct SparkPickerRowView: View {
    let spark: Spark
    let index: Int
    let totalItems: Int
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack {
                    Text(spark.name).font(.body).foregroundColor(.primary)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark").foregroundColor(.white).padding(4).background(Color.blue).clipShape(Circle()).font(.system(size: 10, weight: .bold))
                    }
                }
                .padding(.vertical, 14).padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if index < totalItems - 1 {
                Divider().background(Color.gray.opacity(0.3)).padding(.leading, 16)
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(index == 0 ? 12 : 0, corners: [.topLeft, .topRight])
        .cornerRadius(index == totalItems - 1 ? 12 : 0, corners: [.bottomLeft, .bottomRight])
    }
}
