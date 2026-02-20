import Foundation
import Combine

class DataCache: ObservableObject {
    static let shared = DataCache()
    
    @Published var cachedUmamusumes: [Umamusume] = []
    @Published var cachedSparks: [Spark] = []
    @Published var isLoading = false
    @Published var lastLoadTime: Date?
    
    private var cancellables = Set<AnyCancellable>()
    private let loadQueue = DispatchQueue(label: "com.app.datacache", qos: .background)
    
    private init() {
        print("📦 DataCache inicializado")
    }
    
    func loadInitialDataIfNeeded() {
        guard cachedUmamusumes.isEmpty || cachedSparks.isEmpty else {
            print("📦 Datos ya cacheados - usando caché")
            return
        }
        
        guard !isLoading else {
            print("📦 Carga ya en progreso")
            return
        }
        
        isLoading = true
        print("� Cargando datos iniciales en caché...")
        
        let group = DispatchGroup()
        var loadedUmamusumes: [Umamusume] = []
        var loadedSparks: [Spark] = []
        
        group.enter()
        APIService.fetchUmamusumes(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json"
        ) { result in
            switch result {
            case .success(let data):
                loadedUmamusumes = data
                print("📦 Umamusumes cargados a caché: \(data.count)")
            case .failure(let error):
                print("❌ Error cargando umamusumes a caché: \(error)")
            }
            group.leave()
        }
        
        group.enter()
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { result in
            switch result {
            case .success(let data):
                loadedSparks = data
                print("📦 Sparks cargados a caché: \(data.count)")
            case .failure(let error):
                print("❌ Error cargando sparks a caché: \(error)")
            }
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.cachedUmamusumes = loadedUmamusumes
            self?.cachedSparks = loadedSparks
            self?.lastLoadTime = Date()
            self?.isLoading = false
            print("✅ Caché inicializado con \(loadedUmamusumes.count) umamusumes y \(loadedSparks.count) sparks")
        }
    }
    
    func refreshCache(completion: (() -> Void)? = nil) {
        loadQueue.async { [weak self] in
            let group = DispatchGroup()
            var loadedUmamusumes: [Umamusume] = []
            var loadedSparks: [Spark] = []
            
            group.enter()
            APIService.fetchUmamusumes(
                urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json"
            ) { result in
                if case .success(let data) = result {
                    loadedUmamusumes = data
                }
                group.leave()
            }
            
            group.enter()
            APIService.fetchSparks(
                urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
            ) { result in
                if case .success(let data) = result {
                    loadedSparks = data
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                self?.cachedUmamusumes = loadedUmamusumes
                self?.cachedSparks = loadedSparks
                self?.lastLoadTime = Date()
                print("✅ Caché actualizado")
                completion?()
            }
        }
    }
}
