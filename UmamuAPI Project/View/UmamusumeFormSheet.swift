import SwiftUI

struct UmamusumeFormSheet: View {
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var vm: UmamusumeFormViewModel
    
    let onSave: (Umamusume) -> Void
    let onSaveToAPI: (Umamusume) -> Void
    
    @State private var showSparkPicker = false
    @State private var showInspirationPicker = false
    @State private var selectedSparkIDs: Set<Int> = []
    @State private var selectedInspirationIDs: Set<Int> = []
    @State private var isEditing: Bool = false
    @State private var isSaving = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                if isSaving {
                    ProgressView("Saving...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                }
                
                mainContent
                    .opacity(isSaving ? 0.3 : 1)
                    .disabled(isSaving)
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(leading: leadingButton, trailing: trailingButton)
            .background(sparkPickerLink)
            .background(inspirationPickerLink)
        }
        .onAppear(perform: onAppear)
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 0) {
            List {
                nameSection
                sparksSection
                inspirationsSection
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            .environment(\.defaultMinListRowHeight, 0)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Name Section
    private var nameSection: some View {
        Group {
            nameHeader
            nameRow
        }
    }
    
    private var nameHeader: some View {
        HStack {
            Text("NAME").font(.title3).fontWeight(.bold).foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 4).padding(.top, 8).padding(.bottom, 4)
        .background(Color.white)
        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
    }
    
    private var nameRow: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Enter name", text: $vm.name)
                    .disabled(!isEditing && vm.mode == .view)
                    .padding(.vertical, 14).padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
    }
    
    // MARK: - Sparks Section
    private var sparksSection: some View {
        Group {
            if !vm.selectedSparks.isEmpty || isEditing {
                sparksHeader
            }
            
            if vm.selectedSparks.isEmpty && isEditing {
                addSparkButton
            } else {
                sparksList
                if isEditing {
                    addSparkButton
                        .padding(.top, 8)
                }
            }
        }
    }
    
    private var sparksHeader: some View {
        HStack {
            Text("SPARKS").font(.title3).fontWeight(.bold).foregroundColor(.primary)
            Spacer()
            Text("\(vm.selectedSparks.count) items").font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.horizontal, 4).padding(.top, 8).padding(.bottom, 4)
        .background(Color.white)
        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
    }
    
    private var sparksList: some View {
        ForEach(Array(vm.selectedSparks.enumerated()), id: \.element.id) { index, spark in
            SparkItemView(
                spark: spark,
                index: index,
                total: vm.selectedSparks.count,
                isEditing: isEditing,
                sparkByID: vm.sparkByID,
                onRarityChange: { newRarity in
                    if let idx = vm.selectedSparks.firstIndex(where: { $0.spark == spark.spark }) {
                        vm.selectedSparks[idx].rarity = newRarity
                    }
                }
            )
            .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
        }
    }
    
    private var addSparkButton: some View {
        VStack(spacing: 0) {
            Button(action: {
                selectedSparkIDs = Set(vm.selectedSparks.map { $0.spark })
                showSparkPicker = true
            }) {
                HStack {
                    Text("Add Spark").font(.body).foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "plus.circle.fill").foregroundColor(.blue).font(.system(size: 16))
                }
                .padding(.vertical, 14).padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
    }
    
    // MARK: - Inspirations Section
    private var inspirationsSection: some View {
        Group {
            inspirationsHeader
            
            if let i1 = vm.inspiration1 {
                InspirationItemView(umamusume: i1)
                    .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            }
            
            if let i2 = vm.inspiration2 {
                InspirationItemView(umamusume: i2)
                    .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
            }
            
            if isEditing {
                addInspirationButton
                    .padding(.top, vm.inspirationsCompact.isEmpty ? 0 : 8)
            }
        }
    }
    
    private var inspirationsHeader: some View {
        HStack {
            Text("INSPIRATIONS").font(.title3).fontWeight(.bold).foregroundColor(.primary)
            Spacer()
            Text("\(vm.inspirationsCompact.count) items").font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.horizontal, 4).padding(.top, 8).padding(.bottom, 4)
        .background(Color.white)
        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
    }
    
    private var addInspirationButton: some View {
        VStack(spacing: 0) {
            Button(action: {
                selectedInspirationIDs = Set(vm.inspirationsCompact.map { $0.id })
                showInspirationPicker = true
            }) {
                HStack {
                    Text("Add Inspirations").font(.body).foregroundColor(.blue)
                    Spacer()
                    Image(systemName: "plus.circle.fill").foregroundColor(.blue).font(.system(size: 16))
                }
                .padding(.vertical, 14).padding(.horizontal, 16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
        .listRowInsets(EdgeInsets()).listRowBackground(Color.clear)
    }
    
    // MARK: - Navigation
    private var leadingButton: some View {
        Button(isEditing ? "Cancel" : "Close") {
            presentationMode.wrappedValue.dismiss()
        }
        .disabled(isSaving)
    }
    
    private var trailingButton: some View {
        Button(isEditing ? "Save" : "Edit") {
            if isEditing {
                saveChanges()
            } else {
                isEditing = true
            }
        }
        .disabled(!vm.canSave || isSaving)
    }
    
    private var sparkPickerLink: some View {
        NavigationLink(
            destination: SparkPickerSheet(
                selectedIDs: $selectedSparkIDs,
                onSave: {
                    updateSelectedSparks()
                    showSparkPicker = false
                },
                onCancel: {
                    showSparkPicker = false
                }
            ),
            isActive: $showSparkPicker
        ) { EmptyView() }.hidden()
    }
    
    // MARK: - Helper Methods
    private func updateSelectedSparks() {
        let newSparks = selectedSparkIDs.map { id in
            Umamusume.UmamusumeSpark(spark: id, rarity: 1)
        }
        
        let existingSparks = vm.selectedSparks
        var updatedSparks: [Umamusume.UmamusumeSpark] = []
        
        for newSpark in newSparks {
            if let existing = existingSparks.first(where: { $0.spark == newSpark.spark }) {
                updatedSparks.append(existing)
            } else {
                updatedSparks.append(newSpark)
            }
        }
        
        vm.selectedSparks = updatedSparks
    }
    
    private var inspirationPickerLink: some View {
        NavigationLink(
            destination: UmamusumePickerSheet(
                viewModel: UmamusumePickerViewModel(
                    items: vm.umamusumeAll,
                    selectedIDs: $selectedInspirationIDs,
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
        ) { EmptyView() }.hidden()
    }
    
    private var title: String {
        switch vm.mode {
        case .create: return "New Umamusume"
        case .edit: return isEditing ? "Edit Umamusume" : "Umamusume"
        case .view: return isEditing ? "Edit Umamusume" : "Umamusume"
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
    
    private func saveChanges() {
        let updatedUmamusume = vm.toUmamusume()
        
        onSave(updatedUmamusume)
        
        isSaving = true
        onSaveToAPI(updatedUmamusume)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Spark Item View
struct SparkItemView: View {
    let spark: Umamusume.UmamusumeSpark
    let index: Int
    let total: Int
    let isEditing: Bool
    let sparkByID: [Int: Spark]
    let onRarityChange: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if let sparkName = sparkByID[spark.spark]?.name {
                    Text("\(spark.spark) - \(sparkName)").font(.body).foregroundColor(.primary)
                } else {
                    Text("\(spark.spark) - Spark \(spark.spark)").font(.body).foregroundColor(.primary)
                }
                
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
            .padding(.vertical, 14).padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if index < total - 1 {
                Divider().background(Color.gray.opacity(0.3)).padding(.leading, 16)
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(index == 0 ? 12 : 0, corners: [.topLeft, .topRight])
        .cornerRadius(index == total - 1 ? 12 : 0, corners: [.bottomLeft, .bottomRight])
    }
}

// MARK: - Inspiration Item View
struct InspirationItemView: View {
    let umamusume: Umamusume
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(umamusume.id) - \(umamusume.name)").font(.body).foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 14).padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(8)
    }
}
