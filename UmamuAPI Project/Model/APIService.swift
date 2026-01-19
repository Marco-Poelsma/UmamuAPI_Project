//
//  APIService.swift
//  UmamuAPI Project
//
//  Created by alumne on 19/01/2026.
//

import Foundation
struct APIService{
    
    static func fetchBreeds(urlString: String,completion: @escaping(Result<[Breed],APIError>)->Void){
            
            guard let url = URL(string: urlString) else{
                completion(Result.failure(APIError.invalidURL))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url){ data, response, error in
                
                if let errorResponse = error {
                    completion(Result.failure(APIError.urlSessionError(errorResponse)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(Result.failure(APIError.invalidResponse))
                    return
                }
                
                if let dataResponse = data{
                    do{
                        let breeds = try JSONDecoder().decode([Breed].self, from: dataResponse)
                        completion(Result.success(breeds))
                    }catch{
                        completion(Result.failure(APIError.decodingFailed(error)))
                    }
                }
                
                
                
            }
            task.resume()
    }
    
    static func fetchImage(for breedId: String, completion: @escaping (Result<BreedImage?, APIError>) -> Void) {
        guard let url = URL(string: "https://api.thecatapi.com/v1/images/search?breed_ids=\(breedId)") else{
            completion(.failure(APIError.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let errorSession = error {
                completion(.failure(APIError.urlSessionError(errorSession)))
                return
            }else if let responseSession = response as? HTTPURLResponse,
                        !(200...299).contains(responseSession.statusCode){
                completion(Result.failure(APIError.invalidResponse))
            }else if let dataSession = data{
                do {
                    let images = try JSONDecoder().decode([BreedImage].self, from: dataSession)
                    completion(.success(images.first))
                } catch {
                    completion(.failure(APIError.decodingFailed(error)))
                }
            }
            
        }.resume()
    }
    
    static func fetchBreedsWithImages(stringUrl: String, completion: @escaping (Result<[Breed], APIError>) -> Void) {
        fetchBreeds(urlString: "https://api.thecatapi.com/v1/breeds?limit=5") { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(var breeds):
                let dispatchGroup = DispatchGroup()
                
                for index in breeds.indices {
                    dispatchGroup.enter()
                    fetchImage(for: breeds[index].id) { imageResult in
                        switch imageResult {
                        case .failure(let error):
                            print("Failed to fetch image for \(breeds[index].name): \(error.localizedDescription)")
                        case .success(let image):
                            breeds[index].image = image
                        }
                        dispatchGroup.leave()
                    }
                }
                
                dispatchGroup.notify(queue: .main) {
                    completion(.success(breeds))
                }
            }
        }
}
}
