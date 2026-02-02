import SwiftUI

struct UmamusumeListView: View {

    @StateObject private var vm = UmamusumeViewModel()
    @State private var searchText = ""

    var filteredUmamusumes: [Umamusume] {
        if searchText.isEmpty {
            return vm.umamusumes
        } else {
            return vm.umamusumes.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                String($0.id).contains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {

                    // Corner radius compartido
                    let radius: CGFloat = 20

                    // MARK: - BARRA DE BÚSQUEDA
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Buscar por nombre o ID...", text: $searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(radius)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                    // MARK: - LISTA
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredUmamusumes) { u in
                                StyledRowView(
                                    title: u.name,
                                    id: u.id,
                                    isFavorite: u.isFavourite,
                                    showsFavorite: true,
                                    accessory: .detailsWithFavorite,
                                    onFavoriteTap: {
                                        vm.toggleFavourite(for: u.id)
                                    }
                                )

                                Divider()
                            }
                        }
                        .background(Color(UIColor.secondarySystemFill))
                        .cornerRadius(radius)
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Umamusume")
        }
        .onAppear {
            vm.loadData()
        }
    }
}
