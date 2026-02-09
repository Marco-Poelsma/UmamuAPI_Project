import SwiftUI

struct UmamusumePickerSheet: View {

    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var vm = UmamusumeViewModel()

    let onSelect: (Umamusume) -> Void

    var body: some View {
        NavigationView {
            List(vm.umamusumes) { u in
                Button(action: {
                    onSelect(u)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text(u.name)
                }
            }
            .navigationBarTitle("Select Inspiration")
        }
        .onAppear {
            vm.loadData()
        }
    }
}
