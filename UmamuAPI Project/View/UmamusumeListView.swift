import SwiftUI

struct UmamusumeListView: View {

    @StateObject private var vm = UmamusumeViewModel()

    var body: some View {
        NavigationView {
            List(vm.umamusumes) { u in
                VStack(alignment: .leading, spacing: 8) {

                    // 🐴 Nombre Umamusume
                    Text(u.name)
                        .font(.headline)

                    // ✨ Sparks con nombre + rareza
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(u.sparks) { sparkRef in
                            if let spark = vm.sparkByID[sparkRef.spark] {
                                HStack {
                                    Text(spark.name)
                                    Spacer()
                                    Text("⭐️ \(sparkRef.rarity)")
                                }
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            }
                        }
                    }

                    // 💡 Inspiraciones con nombre
                    HStack {
                        Text("Inspiración:")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(vm.umamusumeByID[u.inspirationID1]?.name ?? "—")
                            .font(.caption)

                        Text("•")

                        Text(vm.umamusumeByID[u.inspirationID2]?.name ?? "—")
                            .font(.caption)
                    }
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("🐴 Umamusume")
        }
        .onAppear {
            vm.loadData()
        }
    }
}
