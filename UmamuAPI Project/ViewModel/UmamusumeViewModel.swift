import Foundation
import Combine

class UmamusumeViewModel: ObservableObject {
    
    @Published var umamusumes: [Umamusume] = []
    @Published var sparks: [Spark] = []
    @Published var isSyncing = false
    @Published var lastUpdated: Date?
    @Published var isAutoRefreshEnabled = true
    
    private let syncManager = SyncManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var isSavingInProgress = false
    private var autoRefreshTimer: Timer?
    private var refreshCancellable: AnyCancellable?
    
    
    init() {
        syncManager.$isSyncing
            .assign(to: &$isSyncing)
        
        startAutoRefresh()
    }
    
    deinit {
        stopAutoRefresh()
    }
    
    // MARK: - Auto Refresh
    
    func startAutoRefresh() {
        stopAutoRefresh() // Detener cualquier timer existente
        
        print("⏰ Iniciando auto-refresh cada 5 segundos")
        
        // Usar Timer para actualizar cada 5 segundos
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isAutoRefreshEnabled else { return }
            
            print("🔄 Auto-refresh: cargando datos de la API...")
            self.loadUmamusumesFromAPI()
        }
        
        // También podemos usar Combine para más control
        setupCombineRefresh()
    }
    
    func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
        refreshCancellable?.cancel()
        refreshCancellable = nil
        print("⏹️ Auto-refresh detenido")
    }
    
    func toggleAutoRefresh() {
        isAutoRefreshEnabled.toggle()
        if isAutoRefreshEnabled {
            startAutoRefresh()
        } else {
            stopAutoRefresh()
        }
    }
    
    private func setupCombineRefresh() {
        // Alternativa usando Combine para más control
        refreshCancellable = Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isAutoRefreshEnabled else { return }
                print("🔄 Combine refresh: cargando datos...")
                self.loadUmamusumesFromAPI()
            }
    }
    
    // MARK: - Data Loading
    
    func loadData() {
        loadUmamusumes()
        loadSparks()
    }
    
    func loadUmamusumes() {
        loadUmamusumesFromAPI()
    }
    
    private func loadUmamusumesFromAPI() {
        APIService.fetchUmamusumes(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json"
        ) { [weak self] result in
            switch result {
            case .success(let data):
                let favourites = FavouritesStore.shared.load()
                let mapped = data.map { u -> Umamusume in
                    var copy = u
                    copy.isFavourite = favourites.contains(u.id)
                    return copy
                }
                let sorted = self?.sortUmamusumes(mapped) ?? mapped
                
                DispatchQueue.main.async {
                    self?.umamusumes = sorted
                    self?.lastUpdated = Date()
                    print("✅ Datos actualizados desde API: \(sorted.count) umamusumes")
                }
                
            case .failure(let error):
                print("❌ Error loading umamusumes from API: \(error)")
            }
        }
    }
    
    private func loadSparks() {
        APIService.fetchSparks(
            urlString: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/spark.data.json"
        ) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.sparks = data
                }
            case .failure(let error):
                print("❌ Error loading sparks: \(error)")
            }
        }
    }
    
    // MARK: - CRUD Operations
    
    func add(_ umamusume: Umamusume) {
        umamusumes.append(umamusume)
        umamusumes = sortUmamusumes(umamusumes)
        saveToAPI()
    }
    
    func update(_ umamusume: Umamusume) {
        guard let idx = umamusumes.firstIndex(where: { $0.id == umamusume.id }) else { return }
        umamusumes[idx] = umamusume
        umamusumes = sortUmamusumes(umamusumes)
        saveToAPI()
    }
    
    func delete(ids: [Int]) {
        guard umamusumes.count - ids.count >= 3 else { return }
        
        umamusumes.removeAll { ids.contains($0.id) }
        
        var favourites = FavouritesStore.shared.load()
        ids.forEach { favourites.remove($0) }
        FavouritesStore.shared.save(favourites)
        
        saveToAPI()
    }
    
    func toggleFavourite(for id: Int) {
        guard let index = umamusumes.firstIndex(where: { $0.id == id }) else { return }
        umamusumes[index].isFavourite.toggle()
        FavouritesStore.shared.toggle(id: id)
        saveToAPI()
    }
    
    // MARK: - Spark Operations
    
    func addSpark(_ spark: Spark) {
        sparks.append(spark)
        saveSparksToAPI()
    }
    
    func updateSpark(_ spark: Spark) {
        guard let idx = sparks.firstIndex(where: { $0.id == spark.id }) else { return }
        sparks[idx] = spark
        saveSparksToAPI()
    }
    
    func deleteSpark(id: Int) {
        sparks.removeAll { $0.id == id }
        saveSparksToAPI()
    }
    
    // MARK: - API Sync Methods
    
    func saveToAPI(completion: ((Bool) -> Void)? = nil) {
        print("💾 Guardando \(umamusumes.count) umamusumes en API...")
        
        guard !isSyncing && !isSavingInProgress else {
            print("⚠️ Ya hay una sincronización en curso - ignorando llamada")
            completion?(false)
            return
        }
        
        isSavingInProgress = true
        
        syncManager.syncUmamusumes(umamusumes) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSavingInProgress = false
                switch result {
                case .success:
                    print("✅ Umamusumes guardados en GitHub correctamente")
                    completion?(true)
                case .failure(let error):
                    print("❌ Error guardando umamusumes: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }
    
    func saveSparksToAPI(completion: ((Bool) -> Void)? = nil) {
        print("💾 Guardando \(sparks.count) sparks en API...")
        
        guard !isSyncing && !isSavingInProgress else {
            print("⚠️ Ya hay una sincronización en curso - ignorando llamada")
            completion?(false)
            return
        }
        
        isSavingInProgress = true
        
        syncManager.syncSparks(sparks) { [weak self] result in
            DispatchQueue.main.async {
                self?.isSavingInProgress = false
                switch result {
                case .success:
                    print("✅ Sparks guardados en GitHub correctamente")
                    completion?(true)
                case .failure(let error):
                    print("❌ Error guardando sparks: \(error.localizedDescription)")
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: - Sync Methods (for backward compatibility)
    
    func syncUmamusumes() {
        saveToAPI()
    }
    
    func syncSparks() {
        saveSparksToAPI()
    }
    
    // MARK: - Lookups
    
    var sparkByID: [Int: Spark] {
        Dictionary(uniqueKeysWithValues: sparks.map { ($0.id, $0) })
    }
    
    var umamusumeByID: [Int: Umamusume] {
        Dictionary(uniqueKeysWithValues: umamusumes.map { ($0.id, $0) })
    }
    
    // MARK: - Sorting
    
    func sortUmamusumes(_ list: [Umamusume], bySpark sparkID: Int? = nil) -> [Umamusume] {
        list.sorted { u1, u2 in
            if let sparkID = sparkID {
                let stars1 = u1.sparks.first(where: { $0.spark == sparkID })?.rarity ?? 0
                let stars2 = u2.sparks.first(where: { $0.spark == sparkID })?.rarity ?? 0
                
                if stars1 != stars2 {
                    return stars1 > stars2
                }
            }
            
            if u1.isFavourite != u2.isFavourite {
                return u1.isFavourite && !u2.isFavourite
            }
            
            if u1.name < u2.name {
                return u1.name < u2.name
            }
            
            return u1.id < u2.id
        }
    }
}
