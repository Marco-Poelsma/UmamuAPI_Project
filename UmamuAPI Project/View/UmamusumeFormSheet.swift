import SwiftUI

struct UmamusumeFormSheet: View {

    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var vm: UmamusumeFormViewModel

    @State private var showSparkPicker = false
    @State private var showInspirationPicker = false

    @State private var selectedSparkIDs: Set<Int> = []
    @State private var selectedInspirationIDs: Set<Int> = []

    var body: some View {
        NavigationView {
            List {

                Section(header: Text("Name")) {
                    TextField("Enter name", text: $vm.name)
                        .disabled(vm.isReadOnly)
                }

                Section(header: Text("Sparks")) {

                    ForEach(vm.selectedSparks) { spark in
                        let sparkData = vm.sparkByID[spark.spark]
                        Text("\(spark.spark) - \(sparkData?.name ?? "Unknown")")
                    }

                    if !vm.isReadOnly {
                        Button("Add Spark") {
                            selectedSparkIDs = Set(vm.selectedSparks.map { $0.spark })
                            showSparkPicker = true
                        }
                    }
                }

                Section(header: Text("Inspirations")) {

                    if let i1 = vm.inspiration1 {
                        Text("\(i1.id) - \(i1.name)")
                    }

                    if let i2 = vm.inspiration2 {
                        Text("\(i2.id) - \(i2.name)")
                    }

                    if !vm.isReadOnly {
                        Button("Add Inspirations") {
                            selectedInspirationIDs = Set(vm.inspirationsCompact.map { $0.id })
                            showInspirationPicker = true
                        }
                    }
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    presentationMode.wrappedValue.dismiss()
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
        }
    }

    private var title: String {
        switch vm.mode {
        case .create: return "New Umamusume"
        case .edit: return "Edit Umamusume"
        case .view: return "Umamusume"
        }
    }
}
