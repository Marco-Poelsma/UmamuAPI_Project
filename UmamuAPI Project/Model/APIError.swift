import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case urlSessionError(Error)
    case invalidResponse
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .urlSessionError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
