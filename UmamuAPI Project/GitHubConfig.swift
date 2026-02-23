import Foundation

struct GitHubConfig {
    // IMPORTANTE: Reemplaza con tu token real
    // El token debe tener permisos 'repo' para repositorios privados o 'public_repo' para públicos
    
    //MARK: ¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡¡PONER TOKEN AQUÍ!!!!!!!!!!!!!!!!!!!
    static let token = "a"
    
    
    // Para producción, puedes usar variables de entorno:
    // static let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] ?? ""
}
