import Foundation

struct APIService {

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
}
