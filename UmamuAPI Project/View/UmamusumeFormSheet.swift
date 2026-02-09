import SwiftUI

enum ActiveSheet {
    case spark
    case inspiration
}

struct UmamusumeFormSheet: View {

    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var vm: UmamusumeFormViewModel

    @State private var activeSheet: ActiveSheet? = nil

    @State private var selectedSparks: Set<Int> = []
    @State private var selectedInspirations: Set<Int> = []

    var body: some View {
        NavigationView {
            List {

                Section(header: Text("Name")) {
                    TextField("Enter name", text: $vm.name)
                        .disabled(vm.isReadOnly)
                }

                Section(header: Text("Sparks")) {
                    ForEach(vm.selectedSparks) { spark in
                        Text("Spark \(spark.spark) - Rarity \(spark.rarity)")
                    }

                    if !vm.isReadOnly {
                        Button(action: {
                            selectedSparks = Set(vm.selectedSparks.map { $0.spark })
                            activeSheet = .spark
                        }) {
                            Text("Add Spark")
                        }
                    }
                }

                Section(header: Text("Inspirations")) {

                    inspirationRow(
                        title: "Inspiration 1",
                        value: vm.inspiration1?.name,
                        action: {
                            activeSheet = .inspiration
                            selectedInspirations = Set(vm.inspirationsCompact.map { $0.id })
                        }
                    )

                    inspirationRow(
                        title: "Inspiration 2",
                        value: vm.inspiration2?.name,
                        action: {
                            activeSheet = .inspiration
                            selectedInspirations = Set(vm.inspirationsCompact.map { $0.id })
                        }
                    )
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(
                leading: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: saveButton
            )
        }
        .sheet(
            isPresented: Binding(
                get: { self.activeSheet != nil },
                set: { if !$0 { self.activeSheet = nil } }
            )
        ) {
            if activeSheet == .spark {
                SparkPickerSheet(
                    selectedIDs: $selectedSparks,
                    onSave: {
                        applySparks()
                        activeSheet = nil
                    },
                    onCancel: {
                        activeSheet = nil
                    }
                )
            } else if activeSheet == .inspiration {
                UmamusumePickerSheet(
                    selectedIDs: $selectedInspirations,
                    onSave: {
                        applyInspirations()
                        activeSheet = nil
                    },
                    onCancel: {
                        activeSheet = nil
                    }
                )
            }
        }
    }

    private var title: String {
        switch vm.mode {
        case .create: return "New Umamusume"
        case .edit: return "Edit Umamusume"
        case .view: return "Umamusume"
        }
    }

    private var saveButton: some View {
        Group {
            if vm.mode != .view {
                Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!vm.canSave)
            }
        }
    }

    private func inspirationRow(
        title: String,
        value: String?,
        action: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value ?? "Select")
                .foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !vm.isReadOnly {
                action()
            }
        }
    }

    private func applySparks() {
        let sparksToAdd = selectedSparks.map { Umamusume.UmamusumeSpark(spark: $0, rarity: 1) }
        vm.selectedSparks = sparksToAdd
    }

    private func applyInspirations() {
        let inspirations = vm.umamusumeAll.filter { selectedInspirations.contains($0.id) }
        vm.inspiration1 = inspirations.first
        vm.inspiration2 = inspirations.dropFirst().first
    }
}
