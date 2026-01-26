import SwiftUI

struct UmamusumeListView: View {

    @StateObject private var vm = UmamusumeViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(vm.umamusumes) { u in
                            StyledRowView(
                                title: u.name,
                                id: u.id,
                                showsFavorite: true,
                                accessory: .detailsWithFavorite,
                                onAccessoryTap: {
                                    print("Detalles de \(u.name)")
                                },
                                onFavoriteTap: {
                                    print("Marcada \(u.name) como favorita")
                                }
                            )
                            Divider()
                        }
                    }
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(20)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Umamusume")
        }
        .onAppear {
            vm.loadData()
        }
    }
}
