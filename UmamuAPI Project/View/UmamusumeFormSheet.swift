import SwiftUI

struct UmamusumeFormSheet: View {

    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var vm: UmamusumeFormViewModel

    let onSave: (Umamusume) -> Void

    @State private var showSparkPicker = false
    @State private var showInspirationPicker = false

    @State private var selectedSparkIDs: Set<Int> = []
    @State private var selectedInspirationIDs: Set<Int> = []

    @State private var isEditing: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    List {
                        // MARK: NAME HEADER
                        sectionHeader(title: "NAME", count: nil)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        
                        // MARK: NAME ROW
                        nameRow
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        
                        // MARK: SPARKS HEADER
                        if !vm.selectedSparks.isEmpty || isEditing {
                            sectionHeader(title: "SPARKS", count: vm.selectedSparks.count)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                        
                        // MARK: SPARKS CONTENT
                        if vm.selectedSparks.isEmpty && isEditing {
                            addSparkRow
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        } else {
                            ForEach(Array(vm.selectedSparks.enumerated()), id: \.element.id) { index, spark in
                                sparkRow(spark: spark, index: index, category: vm.selectedSparks)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                            
                            if isEditing {
                                addSparkRow
                                    .padding(.top, vm.selectedSparks.isEmpty ? 0 : 8)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                        }
                        
                        // MARK: INSPIRATIONS HEADER
                        sectionHeader(title: "INSPIRATIONS", count: vm.inspirationsCompact.count)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        
                        // MARK: INSPIRATIONS CONTENT
                        if let i1 = vm.inspiration1 {
                            inspirationRow(umamusume: i1, index: 0, category: vm.inspirationsCompact)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                        
                        if let i2 = vm.inspiration2 {
                            inspirationRow(umamusume: i2, index: 1, category: vm.inspirationsCompact)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                        
                        if isEditing && vm.inspirationsCompact.count < 2 {
                            addInspirationRow
                                .padding(.top, vm.inspirationsCompact.isEmpty ? 0 : 8)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
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
            .navigationBarItems(
                leading: Button(isEditing ? "Cancel" : "Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        let updated = vm.toUmamusume()
                        onSave(updated)
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        isEditing = true
                    }
                }
                .disabled(!vm.canSave)
            )
            .background(
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
            )
            .background(
                NavigationLink(
                    destination: UmamusumePickerSheet(
                        items: vm.umamusumeAll,
                        selectedIDs: $selectedInspirationIDs,
                        onSave: {
                            vm.setInspirations(from: selectedInspirationIDs)
                            showInspirationPicker = false
                        },
                        onCancel: {
                            showInspirationPicker = false
                        }
                    ),
                    isActive: $showInspirationPicker
                ) { EmptyView() }
                .hidden()
            )
        }
        .onAppear {
            vm.loadData()
            isEditing = (vm.mode != .view)
            
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableViewHeaderFooterView.appearance().tintColor = .clear
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().separatorColor = .clear
            UITableView.appearance().tableFooterView = UIView()
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String, count: Int?) -> some View {
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
    
    // MARK: - Name Row
    private var nameRow: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("Enter name", text: $vm.name)
                    .disabled(!isEditing && vm.mode == .view)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
    }
    
    // MARK: - Spark Row
    private func sparkRow(spark: Umamusume.UmamusumeSpark, index: Int, category: [Umamusume.UmamusumeSpark]) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(spark.spark) - \(vm.sparkByID[spark.spark]?.name ?? "Unknown")")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 2) {
                    ForEach(1...3, id: \.self) { i in
                        Image(systemName: i <= spark.rarity ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                            .onTapGesture {
                                guard isEditing else { return }
                                if let idx = vm.selectedSparks.firstIndex(where: { $0.spark == spark.spark }) {
                                    vm.selectedSparks[idx].rarity = i
                                }
                            }
                    }
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            if index < category.count - 1 {
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 16)
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(
            index == 0 && category.count > 0 ? 12 : 0,
            corners: [.topLeft, .topRight]
        )
        .cornerRadius(
            index == category.count - 1 ? 12 : 0,
            corners: [.bottomLeft, .bottomRight]
        )
    }
    
    // MARK: - Add Spark Row
    private var addSparkRow: some View {
        VStack(spacing: 0) {
            Button(action: {
                selectedSparkIDs = Set(vm.selectedSparks.map { $0.spark })
                showSparkPicker = true
            }) {
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
    
    // MARK: - Inspiration Row
    private func inspirationRow(umamusume: Umamusume, index: Int, category: [Umamusume]) -> some View {
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
            
            if index < category.count - 1 {
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.leading, 16)
            }
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(
            index == 0 && category.count > 0 ? 12 : 0,
            corners: [.topLeft, .topRight]
        )
        .cornerRadius(
            index == category.count - 1 ? 12 : 0,
            corners: [.bottomLeft, .bottomRight]
        )
    }
    
    // MARK: - Add Inspiration Row
    private var addInspirationRow: some View {
        VStack(spacing: 0) {
            Button(action: {
                selectedInspirationIDs = Set(vm.inspirationsCompact.map { $0.id })
                showInspirationPicker = true
            }) {
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

    private var title: String {
        switch vm.mode {
        case .create: return "New Umamusume"
        case .edit: return isEditing ? "Edit Umamusume" : "Umamusume"
        case .view: return isEditing ? "Edit Umamusume" : "Umamusume"
        }
    }
}
