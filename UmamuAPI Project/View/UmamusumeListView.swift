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
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    let radius: CGFloat = 20

                    // 🔍 Barra de búsqueda
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
                    .padding(.bottom, 8)

                    // 📋 Lista
                    List {
                        Section {
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
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(
                                    filteredUmamusumes.isFirst(u) ? 20 : 0,
                                    corners: [.topLeft, .topRight]
                                )
                                .cornerRadius(
                                    filteredUmamusumes.isLast(u) ? 20 : 0,
                                    corners: [.bottomLeft, .bottomRight]
                                )
                            }
                            .onDelete(perform: deleteItems)
                        }
                        .listRowInsets(EdgeInsets())
                        .background(Color(UIColor.secondarySystemBackground))
                    }
                    .listStyle(PlainListStyle())
                    .padding(.horizontal, 10)
                    .background(Color.clear)
                }
            }
            .navigationTitle("Umamusume")
            .navigationBarItems(
                leading: Button("Edit") { print("Edit tapped") }
                    .foregroundColor(.blue),

                trailing: Button(action: { print("Add tapped") }) {
                    Image(systemName: "plus")
                }
                .foregroundColor(.blue)
            )
        }
        .onAppear {
            vm.loadData()

            // 🔥 Hace transparente el fondo del List
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredUmamusumes[$0].id }
        vm.delete(ids: idsToDelete)
    }
}
