import SwiftUI

// Modelo para agrupar sparks por nombre
struct SparkCategory: Identifiable {
    let id: Int
    let name: String
    let sparks: [Spark]
    let type: SparkType
    
    // Color base único para esta categoría (basado en su ID para que sea consistente)
    var baseColor: Color {
        // Usar el ID de la categoría como semilla para generar un color único pero consistente
        let seed = id * 67
        
        switch type {
        case .stat:
            // Azules puros: matiz entre 0.55 y 0.65 (evitando los tonos morados/magentas)
            // 0.55 es un azul cielo, 0.65 es un azul más intenso sin llegar a morado
            let hue = 0.55 + (Double(seed % 20) / 100.0) // Rango 0.55 - 0.75
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
            
        case .aptitude:
            // Rosas puros: matiz entre 0.85 y 0.95 (evitando los tonos anaranjados)
            // 0.85 es un rosa/ magenta, 0.95 es un rosa más cálido sin llegar a naranja
            let hue = 0.85 + (Double(seed % 15) / 100.0) // Rango 0.85 - 1.0
            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
            
        default:
            return Color.gray
        }
    }
    
    // Propiedad para obtener los sparks ordenados por ID
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
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(Color.orange)
                        Text("Error: \(errorMessage)")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button(action: {
                            loadCategories()
                        }) {
                            Text("Reintentar")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    ScrollView {
                        // Grid manual de 2 columnas
                        VStack(spacing: 16) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                if categories.count % 2 != 0 && index == categories.count - 1 {
                                    // Último elemento impar - ocupa toda la fila
                                    NavigationLink(
                                        destination: SparkRankingDetailView(category: categories[index])
                                    ) {
                                        CategoryCard(category: categories[index])
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                } else if index % 2 == 0 {
                                    // Cada par de elementos en una fila
                                    HStack(spacing: 16) {
                                        NavigationLink(
                                            destination: SparkRankingDetailView(category: categories[index])
                                        ) {
                                            CategoryCard(category: categories[index])
                                                .frame(maxWidth: .infinity)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        
                                        if index + 1 < categories.count {
                                            NavigationLink(
                                                destination: SparkRankingDetailView(category: categories[index + 1])
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
                    // Filtrar sparks por type "stat" o "aptitude"
                    let filteredSparks = sparks.filter { spark in
                        spark.type == .stat || spark.type == .aptitude
                    }
                    
                    // Agrupar por nombre para crear categorías
                    let sparksByName = Dictionary(grouping: filteredSparks) { $0.name }
                    
                    // Crear categorías con el tipo correspondiente
                    var newCategories: [SparkCategory] = []
                    
                    // Obtener el ID más pequeño de cada grupo para ordenar
                    let sortedGroups = sparksByName.sorted { group1, group2 in
                        let minId1 = group1.value.map { $0.id }.min() ?? 0
                        let minId2 = group2.value.map { $0.id }.min() ?? 0
                        return minId1 < minId2
                    }
                    
                    for (index, (name, sparks)) in sortedGroups.enumerated() {
                        if let type = sparks.first?.type {
                            newCategories.append(SparkCategory(
                                id: index,
                                name: name,
                                sparks: sparks,
                                type: type
                            ))
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
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Fondo de color único según la categoría (azul para stats, rosa para aptitudes)
            category.baseColor
            
            // Gradiente estilo App Store (exactamente igual que antes)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.4)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Título alineado abajo izquierda
            Text(category.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
        }
        .frame(height: 90)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isPressed)
        .onTapGesture {
            // El NavigationLink manejará la navegación
        }
    }
}

// Vista de detalle temporal para demostrar el ordenamiento por ID
struct SparkRankingDetailView: View {
    let category: SparkCategory
    
    var body: some View {
        List {
            Section(header: Text("Sparks ordenados por ID")) {
                ForEach(category.sparksSortedByID) { spark in
                    HStack {
                        Text(spark.name)
                            .font(.headline)
                        Spacer()
                        Text("ID: \(spark.id)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle(category.name)
        .listStyle(InsetGroupedListStyle())
    }
}

// Vista previa
struct SparkRankingsView_Previews: PreviewProvider {
    static var previews: some View {
        SparkRankingsView()
    }
}
