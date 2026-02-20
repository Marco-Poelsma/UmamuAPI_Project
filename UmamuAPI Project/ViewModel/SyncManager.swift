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
    private let syncQueue = DispatchQueue(label: "com.app.syncmanager", qos: .utility)
    private var isSyncInProgress = false
    private var pendingSyncs: [(type: SyncType, umamusumes: [Umamusume]?, sparks: [Spark]?, completion: ((Result<Void, Error>) -> Void)?)] = []
    private let serialQueue = DispatchQueue(label: "com.app.syncmanager.serial", qos: .utility)
    
    private init() {}
    
    // MARK: - Enums
    enum SyncType: String {
        case umamusumes = "Umamusumes"
        case sparks = "Sparks"
        case both = "Ambos"
    }
    
    // MARK: - Public Methods
    
    func syncUmamusumes(_ umamusumes: [Umamusume], completion: ((Result<Void, Error>) -> Void)? = nil) {
        serialQueue.async { [weak self] in
            self?.enqueueSync(type: .umamusumes, umamusumes: umamusumes, sparks: nil, completion: completion)
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
        serialQueue.async { [weak self] in
            self?.enqueueSync(type: .sparks, umamusumes: nil, sparks: sparks, completion: completion)
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
    
    private func enqueueSync(type: SyncType, umamusumes: [Umamusume]?, sparks: [Spark]?, completion: ((Result<Void, Error>) -> Void)?) {
        pendingSyncs.append((type, umamusumes, sparks, completion))
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
        
        performSync(type: nextSync.type,
                   umamusumes: nextSync.umamusumes,
                   sparks: nextSync.sparks) { [weak self] result in
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
    
    // MARK: - Private Methods
    
    private func performSync(type: SyncType, umamusumes: [Umamusume]? = nil, sparks: [Spark]? = nil, completion: ((Result<Void, Error>) -> Void)? = nil) {
        
        print("🔄 Iniciando sincronización serial de \(type.rawValue)")
        
        if (type == .umamusumes && (umamusumes?.isEmpty ?? true)) ||
           (type == .sparks && (sparks?.isEmpty ?? true)) {
            let error = NSError(domain: "SyncManager", code: -2,
                               userInfo: [NSLocalizedDescriptionKey: "No hay datos para sincronizar"])
            DispatchQueue.main.async {
                completion?(.failure(error))
            }
            return
        }
        
        let syncOperation: ( @escaping (Result<Void, Error>) -> Void) -> Void
        
        switch type {
        case .umamusumes:
            guard let umamusumes = umamusumes else { return }
            syncOperation = { callback in
                APIService.saveUmamusumes(umamusumes, completion: callback)
            }
        case .sparks:
            guard let sparks = sparks else { return }
            syncOperation = { callback in
                APIService.saveSparks(sparks, completion: callback)
            }
        case .both:
            return
        }
        
        syncQueue.async {
            syncOperation { result in
                DispatchQueue.main.async {
                    completion?(result)
                }
            }
        }
    }
}
