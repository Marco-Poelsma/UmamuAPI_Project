import SwiftUI

enum ActiveSheet {
    case spark
    case inspiration1
    case inspiration2
}

struct UmamusumeFormSheet: View {

    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var vm: UmamusumeFormViewModel

    @State private var activeSheet: ActiveSheet? = nil

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
                            activeSheet = ActiveSheet.spark
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
                            activeSheet = ActiveSheet.inspiration1
                        }
                    )

                    inspirationRow(
                        title: "Inspiration 2",
                        value: vm.inspiration2?.name,
                        action: {
                            activeSheet = ActiveSheet.inspiration2
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
            self.sheetContent()
        }
    }

    private func sheetContent() -> AnyView {
        if activeSheet == .spark {
            return AnyView(
                SparkPickerSheet { spark in
                    vm.selectedSparks.append(spark)
                    activeSheet = nil
                }
            )
        }

        if activeSheet == .inspiration1 {
            return AnyView(
                UmamusumePickerSheet { u in
                    vm.inspiration1 = u
                    activeSheet = nil
                }
            )
        }

        if activeSheet == .inspiration2 {
            return AnyView(
                UmamusumePickerSheet { u in
                    vm.inspiration2 = u
                    activeSheet = nil
                }
            )
        }

        return AnyView(EmptyView())
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
                    save()
                }
                .disabled(!vm.canSave)
            }
        }
    }

    private func save() {
        presentationMode.wrappedValue.dismiss()
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
}
