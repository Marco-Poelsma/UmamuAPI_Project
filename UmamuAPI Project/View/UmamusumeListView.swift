import SwiftUI

struct UmamusumeListView: View {

    @StateObject private var vm = UmamusumeViewModel()
    @State private var searchText = ""
    @State private var showCreateSheet = false

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

                    VStack(spacing: 0) {
                        List {
                            Section {
                                ForEach(filteredUmamusumes) { u in
                                    VStack(spacing: 0) {
                                        VStack(spacing: 0) {
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
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 4)

                                            if !filteredUmamusumes.isLast(u) {
                                                Divider()
                                                    .background(Color.gray.opacity(0.6))
                                                    .padding(.leading, 12)
                                                    .padding(.trailing, 12)
                                            }
                                        }
                                        .background(Color(UIColor.secondarySystemFill))
                                        .cornerRadius(
                                            filteredUmamusumes.isFirst(u) ? 20 : 0,
                                            corners: [.topLeft, .topRight]
                                        )
                                        .cornerRadius(
                                            filteredUmamusumes.isLast(u) ? 20 : 0,
                                            corners: [.bottomLeft, .bottomRight]
                                        )
                                    }
                                }
                                .onDelete(perform: deleteItems)
                            }
                            .listRowInsets(EdgeInsets())
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                }
            }
            .navigationTitle("Umamusume")
            .navigationBarItems(
                leading: Button("Edit") {
                    print("Edit tapped")
                },
                trailing: Button(action: {
                    showCreateSheet = true
                }) {
                    Image(systemName: "plus")
                }
                .foregroundColor(.blue)
            )
        }
        .sheet(isPresented: $showCreateSheet) {
            UmamusumeFormSheet(
                vm: UmamusumeFormViewModel(mode: .create)
            )
        }
        .onAppear {
            vm.loadData()

            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableViewHeaderFooterView.appearance().tintColor = .clear
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        let idsToDelete = offsets.map { filteredUmamusumes[$0].id }
        vm.delete(ids: idsToDelete)
    }
}
