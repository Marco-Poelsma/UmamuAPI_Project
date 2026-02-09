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
            List {

                Section(header: Text("Name")) {
                    TextField("Enter name", text: $vm.name)
                        .disabled(!isEditing && vm.mode == .view)
                }

                // MARK: SPARKS
                Section(header: Text("Sparks")) {

                    ForEach(vm.selectedSparks) { spark in
                        HStack {
                            Text("\(spark.spark) - \(vm.sparkByID[spark.spark]?.name ?? "Unknown")")
                            Spacer()

                            HStack(spacing: 2) {
                                ForEach(1...3, id: \.self) { i in
                                    Image(systemName: i <= spark.rarity ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .onTapGesture {
                                            guard isEditing else { return }
                                            if let idx = vm.selectedSparks.firstIndex(where: { $0.spark == spark.spark }) {
                                                vm.selectedSparks[idx].rarity = i
                                            }
                                        }
                                }
                            }
                        }
                    }

                    if isEditing {
                        Button("Add Spark") {
                            selectedSparkIDs = Set(vm.selectedSparks.map { $0.spark })
                            showSparkPicker = true
                        }
                    }
                }

                // MARK: INSPIRATIONS
                Section(header: Text("Inspirations")) {

                    if let i1 = vm.inspiration1 {
                        Text("\(i1.id) - \(i1.name)")
                    }

                    if let i2 = vm.inspiration2 {
                        Text("\(i2.id) - \(i2.name)")
                    }

                    if isEditing {
                        Button("Add Inspirations") {
                            selectedInspirationIDs = Set(vm.inspirationsCompact.map { $0.id })
                            showInspirationPicker = true
                        }
                    }
                }
            }
            .navigationBarTitle(title)
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
        }
    }

    private var title: String {
        switch vm.mode {
        case .create: return "New Umamusume"
        case .edit: return isEditing ? "Edit Umamusume" : "Umamusume"
        case .view: return isEditing ? "Edit Umamusume" : "Umamusume"
        }
    }
}
