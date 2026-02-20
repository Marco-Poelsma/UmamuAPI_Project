import SwiftUI

struct TopRankingView: View {
    
    let category: SparkCategory
    
    @StateObject private var vm = UmamusumeViewModel()
    @State private var searchText = ""
    
    @State private var activeSheet: ActiveSheet?
    
    enum ActiveSheet: Identifiable {
        case view(Umamusume)
        
        var id: Int {
            switch self {
            case .view(let u): return u.id
            }
        }
    }
    
    // Spark activo para la categoría
    private var activeSparkID: Int? {
        category.sparksSortedByID.first?.id
    }
    
    // Filtrar umamusume que tienen el spark de 3 estrellas
    private var umamusumeWithThreeStars: [Umamusume] {
        guard let sparkID = activeSparkID else { return [] }
        
        return vm.umamusumes.filter { umamusume in
            // Buscar si el umamusume tiene este spark con rarity 3
            umamusume.sparks.contains { spark in
                spark.spark == sparkID && spark.rarity == 3
            }
        }
    }
    
    var filteredUmamusumes: [Umamusume] {
        let baseList = umamusumeWithThreeStars
        
        if searchText.isEmpty {
            return baseList
        } else {
            return baseList.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                String($0.id).contains(searchText)
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                let radius: CGFloat = 20
                
                // 🔎 Search Bar
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
                .padding(.vertical, 8)
                
                // Mostrar contador de resultados
                HStack {
                    Text("\(filteredUmamusumes.count) umamusume con ★★★")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Spacer()
                }
                .padding(.bottom, 4)
                
                // Lista de Umamusumes
                if filteredUmamusumes.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "star.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No hay umamusume con 3 estrellas en esta categoría")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    ScrollableListContainer(radius: radius) {
                        ForEach(filteredUmamusumes) { u in
                            VStack(spacing: 0) {
                                VStack(spacing: 0) {
                                    
                                    Button(action: { activeSheet = .view(u) }) {
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
                                            .background(Color(UIColor.secondarySystemFill))
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
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
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
                                print("✅ Guardado en API exitoso desde TopRankingView")
                            }
                        }
                    }
                )
            }
        }
        .onAppear {
            vm.loadData()
            
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableViewHeaderFooterView.appearance().tintColor = .clear
        }
    }
}
