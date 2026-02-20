import SwiftUI

struct UmamusumeFormSheet: View {
    // MARK: - Environment
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var vm: UmamusumeFormViewModel
    
    let onSave: (Umamusume) -> Void
    
    @State private var showSparkPicker = false
    @State private var showInspirationPicker = false
    @State private var selectedSparkIDs: Set<Int> = []
    @State private var selectedInspirationIDs: Set<Int> = []
    @State private var isEditing: Bool = false
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    List {
                        nameSection
                        sparksSection
                        inspirationsSection
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .environment(\.defaultMinListRowHeight, 0)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(leading: leadingButton, trailing: trailingButton)
            .background(sparkPickerLink)
            .background(inspirationPickerLink)
        }
        .onAppear(perform: onAppear)
    }
    
    // MARK: - Sections
    private var nameSection: some View {
        Group {
            SectionHeaderView(title: "NAME")
            NameRowView(name: $vm.name, isDisabled: !isEditing && vm.mode == .view)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        }
    }
    
    private var sparksSection: some View {
        Group {
            if !vm.selectedSparks.isEmpty || isEditing {
                SectionHeaderView(title: "SPARKS", count: vm.selectedSparks.count)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            if vm.selectedSparks.isEmpty && isEditing {
                AddSparkRow(action: openSparkPicker)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            } else {
                ForEach(vm.selectedSparks, id: \.id) { spark in
                    SparkRowView(
                        spark: spark,
                        isEditing: isEditing,
                        onRarityChange: { newRarity in
                            updateSparkRarity(spark: spark, rarity: newRarity)
                        }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
                if isEditing {
                    AddSparkRow(action: openSparkPicker)
                        .padding(.top, vm.selectedSparks.isEmpty ? 0 : 8)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
        }
    }
    
    private var inspirationsSection: some View {
        Group {
            SectionHeaderView(title: "INSPIRATIONS", count: vm.inspirationsCompact.count)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            
            if let i1 = vm.inspiration1 {
                InspirationRowView(umamusume: i1)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            if let i2 = vm.inspiration2 {
                InspirationRowView(umamusume: i2)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            if isEditing {
                AddInspirationRow(action: openInspirationPicker)
                    .padding(.top, vm.inspirationsCompact.isEmpty ? 0 : 8)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
        }
    }
    
    // MARK: - Navigation
    private var leadingButton: some View {
        Button(isEditing ? "Cancel" : "Close") {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private var trailingButton: some View {
        Button(isEditing ? "Save" : "Edit") {
            if isEditing {
                let updated = vm.toUmamusume()
                onSave(updated)
                presentationMode.wrappedValue.dismiss()
            } else {
                isEditing = true
            }
        }
        .disabled(!vm.canSave)
    }
    
    private var sparkPickerLink: some View {
        NavigationLink(
            destination: SparkPickerSheet(
                selectedIDs: $selectedSparkIDs,
                onSave: {
                    vm.selectedSparks = selectedSparkIDs.map {
                        Umamusume.UmamusumeSpark(spark: $0, rarity: 1)
                    }
                    showSparkPicker = false
                },
                onCancel: {
                    showSparkPicker = false
                }
            ),
            isActive: $showSparkPicker
        ) { EmptyView() }
        .hidden()
    }
    
    private var inspirationPickerLink: some View {
        NavigationLink(
            destination: UmamusumePickerSheet(
                viewModel: UmamusumePickerViewModel(
                    items: vm.umamusumeAll,
                    selectedIDs: selectedInspirationIDs,
                    onSave: {
                        vm.setInspirations(from: selectedInspirationIDs)
                        showInspirationPicker = false
                    },
                    onCancel: {
                        showInspirationPicker = false
                    }
                )
            ),
            isActive: $showInspirationPicker
        ) { EmptyView() }
        .hidden()
    }
    
    // MARK: - Actions
    private func openSparkPicker() {
        selectedSparkIDs = Set(vm.selectedSparks.map { $0.spark })
        showSparkPicker = true
    }
    
    private func openInspirationPicker() {
        selectedInspirationIDs = Set(vm.inspirationsCompact.map { $0.id })
        showInspirationPicker = true
    }
    
    private func updateSparkRarity(spark: Umamusume.UmamusumeSpark, rarity: Int) {
        if let idx = vm.selectedSparks.firstIndex(where: { $0.spark == spark.spark }) {
            vm.selectedSparks[idx].rarity = rarity
        }
    }
    
    private func onAppear() {
        vm.loadData()
        isEditing = (vm.mode != .view)
        
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
    
    private var title: String {
        switch vm.mode {
        case .create: return "New Umamusume"
        case .edit: return isEditing ? "Edit Umamusume" : "Umamusume"
        case .view: return isEditing ? "Edit Umamusume" : "Umamusume"
        }
    }
}

// MARK: - Subvistas
struct SectionHeaderView: View {
    let title: String
    var count: Int?
    
    var body: some View {
        HStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            if let count = count {
                Text("\(count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color.white)
    }
}

struct NameRowView: View {
    @Binding var name: String
    let isDisabled: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Enter name", text: $name)
                    .disabled(isDisabled)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
    }
}

struct SparkRowView: View {
    let spark: Umamusume.UmamusumeSpark
    let isEditing: Bool
    let onRarityChange: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(spark.spark) - Spark \(spark.spark)")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= spark.rarity ? "star.fill" : "star")
                            .foregroundColor(.blue)
                            .font(.system(size: 14))
                            .onTapGesture {
                                if isEditing {
                                    onRarityChange(i)
                                }
                            }
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(8)
    }
}

struct AddSparkRow: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Text("Add Spark")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
    }
}

struct InspirationRowView: View {
    let umamusume: Umamusume
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(umamusume.id) - \(umamusume.name)")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(8)
    }
}

struct AddInspirationRow: View {
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                HStack {
                    Text("Add Inspirations")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
    }
}
