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
    
    var filteredUmamusumes: [Umamusume] {
        let baseList: [Umamusume]
        
        if searchText.isEmpty {
            baseList = vm.umamusumes
        } else {
            baseList = vm.umamusumes.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                String($0.id).contains(searchText)
            }
        }
        
        return vm.sortUmamusumes(baseList, bySpark: activeSparkID)
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
                
                // Lista de Umamusumes
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
                }
            }
        }
        .navigationTitle(category.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.loadData()
            
            UITableView.appearance().backgroundColor = .clear
            UITableViewCell.appearance().backgroundColor = .clear
            UITableViewHeaderFooterView.appearance().tintColor = .clear
        }
    }
}
