import Foundation

struct APIService {

    // MARK: - Sparks
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


    // MARK: - Umamusume
    static func fetchUmamusumes(
        urlString: String,
        completion: @escaping (Result<[Umamusume], Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }

            do {
                let response = try JSONDecoder().decode(UmamusumeResponse.self, from: data)
                completion(.success(response.properties))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
