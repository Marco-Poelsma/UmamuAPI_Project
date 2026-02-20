import Foundation
import Combine

class SyncManager: ObservableObject {
    static let shared = SyncManager()
    
    // MARK: - Published Properties
    @Published var isSyncing = false
    @Published var lastSyncError: Error?
    @Published var lastSyncSuccess: Date?
    @Published var lastSyncType: SyncType?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var isSyncInProgress = false
    private var pendingSyncs: [(id: String, type: SyncType, umamusumes: [Umamusume]?, sparks: [Spark]?, completion: ((Result<Void, Error>) -> Void)?)] = []
    private let syncQueue = DispatchQueue(label: "com.app.syncmanager.background",
                                          qos: .background,
                                          attributes: .concurrent)
    private let serialQueue = DispatchQueue(label: "com.app.syncmanager.serial",
                                            qos: .background)
    
    private init() {}
    
    // MARK: - Enums
    enum SyncType: String {
        case umamusumes = "Umamusumes"
        case sparks = "Sparks"
        case both = "Ambos"
    }
    
    // MARK: - Public Methods
    
    func syncUmamusumes(_ umamusumes: [Umamusume], completion: ((Result<Void, Error>) -> Void)? = nil) {
        let syncId = UUID().uuidString
        serialQueue.async { [weak self] in
            self?.enqueueSync(id: syncId, type: .umamusumes, umamusumes: umamusumes, sparks: nil, completion: completion)
        }
    }
    
    func syncUmamusumes(_ umamusumes: [Umamusume]) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            self?.syncUmamusumes(umamusumes) { result in
                switch result {
                case .success:
                    promise(.success(()))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func syncSparks(_ sparks: [Spark], completion: ((Result<Void, Error>) -> Void)? = nil) {
        let syncId = UUID().uuidString
        serialQueue.async { [weak self] in
            self?.enqueueSync(id: syncId, type: .sparks, umamusumes: nil, sparks: sparks, completion: completion)
        }
    }
    
    func syncSparks(_ sparks: [Spark]) -> AnyPublisher<Void, Error> {
        Future { [weak self] promise in
            self?.syncSparks(sparks) { result in
                switch result {
                case .success:
                    promise(.success(()))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
    
    func syncAll(umamusumes: [Umamusume], sparks: [Spark]) -> AnyPublisher<Void, Error> {
        Publishers.Zip(
            syncUmamusumes(umamusumes),
            syncSparks(sparks)
        )
        .map { _ in () }
        .eraseToAnyPublisher()
    }
    
    func resetSyncState() {
        DispatchQueue.main.async {
            self.isSyncing = false
            self.lastSyncError = nil
        }
    }
    
    // MARK: - Private Queue Management
    
    private func enqueueSync(id: String, type: SyncType, umamusumes: [Umamusume]?, sparks: [Spark]?, completion: ((Result<Void, Error>) -> Void)?) {
        // Verificar si ya hay una sincronización idéntica pendiente
        let hasIdenticalPending = pendingSyncs.contains { existing in
            existing.type == type &&
            ((type == .umamusumes && existing.umamusumes?.count == umamusumes?.count) ||
             (type == .sparks && existing.sparks?.count == sparks?.count))
        }
        
        if !hasIdenticalPending {
            pendingSyncs.append((id, type, umamusumes, sparks, completion))
            print("📋 Sincronización encolada: \(type.rawValue) (ID: \(id.prefix(8)))")
        } else {
            print("⚠️ Sincronización idéntica ya en cola - ignorando")
            DispatchQueue.main.async {
                completion?(.success(()))
            }
        }
        
        processNextSync()
    }
    
    private func processNextSync() {
        guard !isSyncInProgress, let nextSync = pendingSyncs.first else { return }
        
        isSyncInProgress = true
        pendingSyncs.removeFirst()
        
        DispatchQueue.main.async {
            self.isSyncing = true
            self.lastSyncError = nil
            self.lastSyncType = nextSync.type
        }
        
        // Pequeño delay antes de procesar
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.performSync(
                type: nextSync.type,
                umamusumes: nextSync.umamusumes,
                sparks: nextSync.sparks
            ) { result in
                nextSync.completion?(result)
                
                self?.serialQueue.async {
                    self?.isSyncInProgress = false
                    self?.processNextSync()
                }
                
                DispatchQueue.main.async {
                    self?.isSyncing = false
                    switch result {
                    case .success:
                        self?.lastSyncSuccess = Date()
                        print("✅ \(nextSync.type.rawValue) sincronizados correctamente")
                    case .failure(let error):
                        self?.lastSyncError = error
                        print("❌ Error sincronizando \(nextSync.type.rawValue): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func performSync(type: SyncType, umamusumes: [Umamusume]? = nil, sparks: [Spark]? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        
        print("🔄 Iniciando sincronización serial de \(type.rawValue)")
        
        // VALIDACIÓN - esto SÍ puede ir en main porque es rápido
        if (type == .umamusumes && (umamusumes?.isEmpty ?? true)) ||
           (type == .sparks && (sparks?.isEmpty ?? true)) {
            let error = NSError(domain: "SyncManager", code: -2,
                               userInfo: [NSLocalizedDescriptionKey: "No hay datos para sincronizar"])
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        // Todo lo pesado va a background
        syncQueue.async { [weak self] in
            // Crear una estructura con los datos necesarios para evitar retain cycles
            let datosSincronizacion: (type: SyncType, umamusumes: [Umamusume]?, sparks: [Spark]?)
            datosSincronizacion = (type, umamusumes, sparks)
            
            // Ejecutar la operación pesada
            self?.ejecutarOperacionPesada(datos: datosSincronizacion) { result in
                // Volver al main solo para el completion
                DispatchQueue.main.async {
                    completion?(result)
                }
            }
        }
    }
    private func ejecutarOperacionPesada(datos: (type: SyncType, umamusumes: [Umamusume]?, sparks: [Spark]?),
                                         completion: @escaping (Result<Void, Error>) -> Void) {
        
        switch datos.type {
        case .umamusumes:
            guard let umamusumes = datos.umamusumes else { return }
            APIService.saveUmamusumes(umamusumes, completion: completion)
            
        case .sparks:
            guard let sparks = datos.sparks else { return }
            APIService.saveSparks(sparks, completion: completion)
            
        case .both:
            return
        }
    }
}
