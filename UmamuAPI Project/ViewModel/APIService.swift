import Foundation

// MARK: - APIService
struct APIService {
    
    private static var activeGithubServices: [GitHubService] = []
    
    // MARK: - Fetch Methods
    
    static func fetchSparks(
        urlString: String,
        completion: @escaping (Result<[Spark], APIError>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.urlSessionError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(SparkResponse.self, from: data)
                completion(.success(response.sparks))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }.resume()
    }
    
    static func fetchUmamusumes(
        urlString: String,
        completion: @escaping (Result<[Umamusume], Error>) -> Void
    ) {
        guard let url = URL(string: "https://raw.githubusercontent.com/Marco-Poelsma/UmamuAPI/refs/heads/master/data/umamusume.data.json") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.invalidResponse))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(UmamusumeResponse.self, from: data)
                completion(.success(response.properties))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    // MARK: - Save Methods
    
    static func saveSparks(
        _ sparks: [Spark],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        print("📤 saveSparks llamado con \(sparks.count) sparks")
        let response = SparkResponse(sparks: sparks)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(response)
            print("📦 JSON codificado: \(jsonData.count) bytes")
            
            let githubService = GitHubService.shared
            activeGithubServices.append(githubService)
            
            githubService.updateFile(
                path: "data/spark.data.json",
                with: jsonData,
                commitMessage: "Update sparks data via app - \(Date())"
            ) { result in
                defer {
                    if let index = activeGithubServices.firstIndex(where: { $0 === githubService }) {
                        activeGithubServices.remove(at: index)
                        print("🗑️ Servicio liberado")
                    }
                }
                
                switch result {
                case .success:
                    print("✅ Sparks guardados en GitHub")
                    completion(.success(()))
                case .failure(let error):
                    print("❌ Error guardando sparks: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        } catch {
            print("❌ Error codificando JSON: \(error)")
            completion(.failure(error))
        }
    }
    
    static func saveUmamusumes(
        _ umamusumes: [Umamusume],
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Verificar que NO estamos en el main thread para operaciones pesadas
        dispatchPrecondition(condition: .notOnQueue(.main))
        
        print("📤 saveUmamusumes llamado con \(umamusumes.count) umamusumes en hilo: \(Thread.current)")
        
        let response = UmamusumeResponse(properties: umamusumes)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(response)
            
            // GitHubService.shared.updateFile ya usa URLSession.dataTask (background)
            GitHubService.shared.updateFile(
                path: "data/umamusume.data.json",
                with: jsonData,
                commitMessage: "Update umamusume data via app - \(Date())"
            ) { result in
                // Este completion puede venir de cualquier hilo
                // Aseguramos que el completion final vaya al main si es necesario
                switch result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            
        } catch {
            completion(.failure(error))
        }
    }
}
