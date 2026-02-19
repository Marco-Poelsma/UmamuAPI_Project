import SwiftUI

// Modelo para agrupar sparks por nombre
struct SparkCategory: Identifiable {
    let id: Int
    let name: String
    let sparks: [Spark]
    let type: SparkType
    
    // Color base único para esta categoría
    var baseColor: Color {
        let seed = id * 67
        
        switch type {
        case .stat:
            let hue = 0.55 + (Double(seed % 20) / 100.0)
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
            
        case .aptitude:
            let hue = 0.85 + (Double(seed % 15) / 100.0)
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
            
        default:
            return Color.gray
        }
    }
    
    // Sparks ordenados por ID
    var sparksSortedByID: [Spark] {
        return sparks.sorted { $0.id < $1.id }
    }
}

struct SparkRankingsView: View {
    @State private var categories: [SparkCategory] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    let apiURL = "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("Cargando categorías...")
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Error: \(errorMessage)")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Reintentar") {
                            loadCategories()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                
                                if categories.count % 2 != 0 && index == categories.count - 1 {
                                    
                                    NavigationLink(
                                        destination: TopRankingView(category: categories[index])
                                    ) {
                                        CategoryCard(category: categories[index])
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                } else if index % 2 == 0 {
                                    
                                    HStack(spacing: 16) {
                                        
                                        NavigationLink(
                                            destination: TopRankingView(category: categories[index])
                                        ) {
                                            CategoryCard(category: categories[index])
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if index + 1 < categories.count {
                                            NavigationLink(
                                                destination: TopRankingView(category: categories[index + 1])
                                            ) {
                                                CategoryCard(category: categories[index + 1])
                                                    .frame(maxWidth: .infinity)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        } else {
                                            Spacer()
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitle("Spark Rankings", displayMode: .large)
            .onAppear {
                loadCategories()
            }
        }
    }
    
    private func loadCategories() {
        isLoading = true
        errorMessage = nil
        
        APIService.fetchSparks(urlString: apiURL) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let sparks):
                    
                    let filteredSparks = sparks.filter {
                        $0.type == .stat || $0.type == .aptitude
                    }
                    
                    let sparksByName = Dictionary(grouping: filteredSparks) { $0.name }
                    
                    var newCategories: [SparkCategory] = []
                    
                    let sortedGroups = sparksByName.sorted { g1, g2 in
                        let minId1 = g1.value.map { $0.id }.min() ?? 0
                        let minId2 = g2.value.map { $0.id }.min() ?? 0
                        return minId1 < minId2
                    }
                    
                    for (index, (name, sparks)) in sortedGroups.enumerated() {
                        if let type = sparks.first?.type {
                            newCategories.append(
                                SparkCategory(
                                    id: index,
                                    name: name,
                                    sparks: sparks,
                                    type: type
                                )
                            )
                        }
                    }
                    
                    categories = newCategories
                    
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: SparkCategory
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            category.baseColor
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            Text(category.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(16)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .frame(height: 90)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
