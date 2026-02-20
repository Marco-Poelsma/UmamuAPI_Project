import SwiftUI

struct UmamusumeListView: View {

    @StateObject private var vm = UmamusumeViewModel()
    @State private var searchText = ""

    @State private var activeSheet: ActiveSheet?

    enum ActiveSheet: Identifiable {
        case create
        case view(Umamusume)

        var id: Int {
            switch self {
            case .create: return 0
            case .view(let u): return u.id
            }
        }
    }

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
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    let radius: CGFloat = 20

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.searchBarIcon)

                        TextField("Buscar por nombre o ID...", text: $searchText)
                            .foregroundColor(.searchBarText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.searchBarClearButton)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color.searchBarBackground)
                    .cornerRadius(radius)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        List {
                            Section {
                                ForEach(filteredUmamusumes) { u in
                                    VStack(spacing: 0) {
                                        VStack(spacing: 0) {

                                            Button(action: {
                                                activeSheet = .view(u)
                                            }) {
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
                                            }
                                            .buttonStyle(PlainButtonStyle())

                                            if !filteredUmamusumes.isLast(u) {
                                                Divider()
                                                    .background(Color.lightGray)
                                                    .padding(.leading, 12)
                                                    .padding(.trailing, 12)
                                            }
                                        }
                                        .background(Color.primaryFill)
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
                }
                .foregroundColor(.appBlue),
                
                trailing: Button(action: {
                    activeSheet = .create
                }) {
                    Image(systemName: "plus")
                }
                .foregroundColor(.appBlue)
            )
        }
        .sheet(item: $activeSheet) { sheet in
            Group {
                switch sheet {
                case .create:
                    let formVM = UmamusumeFormViewModel(mode: .create)
                    UmamusumeFormSheet(
                        vm: formVM,
                        onSave: { newUmamusume in
                            vm.add(newUmamusume)
                        },
                        onSaveToAPI: { updated in
                            vm.saveToAPI { success in
                                if success {
                                    print("✅ Guardado en API exitoso")
                                }
                            }
                        }
                    )
                    
                case .view(let u):
                    let formVM = UmamusumeFormViewModel(mode: .view, umamusume: u)
                    UmamusumeFormSheet(
                        vm: formVM,
                        onSave: { updated in
                            vm.update(updated)
                        },
                        onSaveToAPI: { updated in
                            vm.saveToAPI { success in
                                if success {
                                    print("✅ Guardado en API exitoso")
                                }
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            vm.loadData()
            
            // Verificar token al iniciar (opcional)
            GitHubService.shared.verifyToken { isValid, message in
                print("🔐 Token GitHub: \(message)")
            }
            
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
