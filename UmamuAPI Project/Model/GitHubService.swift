import Foundation

// MARK: - Modelos para GitHub API
struct GitHubFileResponse: Codable {
    let sha: String
    let content: String
    let encoding: String
    let size: Int
    let name: String
    let path: String
    let type: String
}

// MARK: - Error específico para GitHub
enum GitHubError: LocalizedError {
    case invalidURL
    case noData
    case encodingFailed
    case apiError(String)
    case missingToken
    case unauthorized
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida para GitHub API"
        case .noData:
            return "No se recibieron datos de GitHub"
        case .encodingFailed:
            return "Error al codificar los datos para GitHub"
        case .apiError(let message):
            return "Error de GitHub API: \(message)"
        case .missingToken:
            return "Token de GitHub no configurado"
        case .unauthorized:
            return "Token inválido o sin permisos suficientes"
        case .rateLimitExceeded:
            return "Límite de tasa de GitHub excedido. Espera unos minutos."
        }
    }
}

// MARK: - GitHub Service
class GitHubService {
    
    static let shared = GitHubService()
    
    // Configuración
    private let repoOwner = "Marco-Poelsma"
    private let repoName = "UmamuAPI"
    private let branch = "master"
    
    // Token desde configuración
    private var token: String {
        return GitHubConfig.token
    }
    
    private init() {
        print("🔑 GitHubService singleton inicializado")
        if token.isEmpty {
            print("⚠️ ADVERTENCIA: Token de GitHub no configurado")
        } else {
            print("✅ Token configurado (longitud: \(token.count) caracteres)")
        }
    }
    
    // MARK: - Actualizar archivo en GitHub
    func updateFile(
        path: String,
        with data: Data,
        commitMessage: String,
        retryCount: Int = 3,
        completion: @escaping (Result<Void, GitHubError>) -> Void
    ) {
        print("📤 Iniciando actualización de archivo: \(path) (intento \(4-retryCount)/3)")
        
        guard !token.isEmpty else {
            print("❌ Token no configurado")
            completion(.failure(.missingToken))
            return
        }
        
        guard !data.isEmpty else {
            print("❌ Datos vacíos para subir")
            completion(.failure(.encodingFailed))
            return
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            let preview = String(jsonString.prefix(200))
            print("📦 JSON preview: \(preview)...")
            print("📦 Tamaño del JSON: \(data.count) bytes")
        }
        
        getFileSHA(path: path) { [weak self] result in
            guard let self = self else {
                completion(.failure(.apiError("Service deallocated")))
                return
            }
            
            switch result {
            case .success(let sha):
                print("✅ SHA obtenido: \(sha.prefix(7))...")
                self.uploadFile(path: path, with: data, sha: sha, commitMessage: commitMessage) { uploadResult in
                    switch uploadResult {
                    case .success:
                        completion(.success(()))
                    case .failure(let error):
                        if case .apiError(let message) = error,
                           message.contains("409") || message.contains("Conflicto"),
                           retryCount > 0 {
                            print("🔄 Conflicto detectado, reintentando... (\(retryCount) intentos restantes)")
                            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                                self.updateFile(path: path, with: data, commitMessage: commitMessage,
                                              retryCount: retryCount - 1, completion: completion)
                            }
                        } else {
                            completion(.failure(error))
                        }
                    }
                }
                
            case .failure(let error):
                print("⚠️ Error obteniendo SHA: \(error.localizedDescription)")
                
                if case .apiError(let message) = error,
                   message.contains("Not Found") || message.contains("404") {
                    print("📝 Archivo no existe, creando nuevo...")
                    self.uploadFile(path: path, with: data, sha: nil, commitMessage: commitMessage, completion: completion)
                } else {
                    completion(.failure(error))
                }
            }
        }
    }
    
    private func getFileSHA(path: String, completion: @escaping (Result<String, GitHubError>) -> Void) {
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/contents/\(path)?ref=\(branch)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("🔍 Obteniendo SHA de: \(urlString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error de red: \(error.localizedDescription)")
                completion(.failure(.apiError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noData))
                return
            }
            
            print("📡 GET Response status: \(httpResponse.statusCode)")
            
            if let remaining = httpResponse.allHeaderFields["X-RateLimit-Remaining"] as? String,
               remaining == "0" {
                completion(.failure(.rateLimitExceeded))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let fileInfo = try decoder.decode(GitHubFileResponse.self, from: data)
                    completion(.success(fileInfo.sha))
                } catch {
                    print("❌ Error decodificando SHA: \(error)")
                    completion(.failure(.apiError("Error decodificando SHA: \(error.localizedDescription)")))
                }
                
            case 401, 403:
                print("❌ Error de autenticación: Token inválido o sin permisos")
                completion(.failure(.unauthorized))
                
            case 404:
                print("📭 Archivo no encontrado")
                completion(.failure(.apiError("Not Found")))
                
            default:
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Error \(httpResponse.statusCode)"
                completion(.failure(.apiError("HTTP \(httpResponse.statusCode): \(message)")))
            }
        }.resume()
    }
    
    private func uploadFile(
        path: String,
        with data: Data,
        sha: String?,
        commitMessage: String,
        completion: @escaping (Result<Void, GitHubError>) -> Void
    ) {
        let urlString = "https://api.github.com/repos/\(repoOwner)/\(repoName)/contents/\(path)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("📤 Subiendo archivo a: \(urlString)")
        print("📝 Commit message: \(commitMessage)")
        print("🔑 SHA proporcionado: \(sha?.prefix(7) ?? "nil")")
        
        let base64Content = data.base64EncodedString()
        print("📦 Tamaño base64: \(base64Content.count) caracteres")
        
        var contentDict: [String: Any] = [
            "message": commitMessage,
            "content": base64Content,
            "branch": branch
        ]
        
        if let sha = sha {
            contentDict["sha"] = sha
            print("🔑 Incluyendo SHA en la petición")
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: contentDict) else {
            completion(.failure(.encodingFailed))
            return
        }
        
        print("📦 Tamaño del request body: \(jsonData.count) bytes")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        print("📡 Enviando petición a GitHub...")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            print("📬 Respuesta recibida de GitHub")
            
            if let error = error {
                print("❌ Error de red: \(error.localizedDescription)")
                completion(.failure(.apiError(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.noData))
                return
            }
            
            print("📡 PUT Response status: \(httpResponse.statusCode)")
            
            if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                print("📬 GitHub Response Body: \(responseString)")
            }
            
            switch httpResponse.statusCode {
            case 200, 201:
                print("✅ Archivo actualizado exitosamente en GitHub")
                completion(.success(()))
                
            case 401, 403:
                print("❌ Error de autenticación")
                completion(.failure(.unauthorized))
                
            case 409:
                print("❌ Conflicto - El archivo fue modificado")
                completion(.failure(.apiError("Conflicto: el archivo fue modificado. Intenta de nuevo.")))
                
            case 422:
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Error de validación"
                completion(.failure(.apiError("Error de validación: \(message)")))
                
            default:
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Error desconocido"
                completion(.failure(.apiError("HTTP \(httpResponse.statusCode): \(message)")))
            }
        }.resume()
    }
    
    func verifyToken(completion: @escaping (Bool, String?) -> Void) {
        let urlString = "https://api.github.com/user"
        guard let url = URL(string: urlString) else {
            completion(false, "URL inválida")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(false, "Respuesta inválida")
                }
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let data = data,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let login = json["login"] as? String {
                    DispatchQueue.main.async {
                        completion(true, "Token válido - Usuario: \(login)")
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(true, "Token válido")
                    }
                }
            case 401:
                DispatchQueue.main.async {
                    completion(false, "Token inválido o expirado")
                }
            case 403:
                DispatchQueue.main.async {
                    completion(false, "Token sin permisos suficientes")
                }
            default:
                DispatchQueue.main.async {
                    completion(false, "Error \(httpResponse.statusCode)")
                }
            }
        }.resume()
    }
}
