import Foundation
import UIKit

class Network {
    
    struct WalleyCheckoutResponse<T: Decodable>: Decodable {
        let id: String
        let data: T?
        let error: WalleyError?
    }
    
    let session: URLSession
    var credentials: Credentials?
    
    static var userAgent: String {
        "WalleyPaySDK/1.0 iOS/\(UIDevice.current.systemVersion)/\(UIDevice.current.model ?? "")"
    }
    
    init(session: URLSession? = nil) {
        if let session = session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = [
                "User-Agent": Self.userAgent
            ]
            let urlSession = URLSession(configuration: configuration)
            self.session = urlSession
        }
    }
    
    func request<T: Decodable>(method: String, host: String, path: String, httpBody: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: host + path) else {
            let error = WalleyError(
                code: 400,
                message: "Malformed url: \(host+path)",
                errors: []
            )
            completion(.failure(error))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = httpBody.data(using: .utf8)
        if let key = credentials?.generateKey(jsonBody: httpBody, path: path) {
            urlRequest.addValue("SharedKey \(key)", forHTTPHeaderField: "Authorization")
        }
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        session.dataTask(with: urlRequest) { data, response, error in
            if let data = data, let decoded: WalleyCheckoutResponse<T> = self.decode(data) {
                if let result = decoded.data {
                    completion(.success(result))
                    return
                } else if let error = decoded.error {
                    print(error.localizedDescription)
                    completion(.failure(error))
                    return
                }
            } else if let error = error {
                print(error.localizedDescription)
                completion(.failure(error))
            } else if let httpResponse = response as? HTTPURLResponse {
                let error = WalleyError(
                    code: httpResponse.statusCode,
                    message: httpResponse.description,
                    errors: []
                )
                print(error.localizedDescription)
                completion(.failure(error))
                return
            } else {
                let error = WalleyError(
                    code: 400,
                    message: "Unknown error",
                    errors: []
                )
                print(error.localizedDescription)
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func decode<T: Decodable>(_ data: Data) -> T? {
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try? decoder.decode(T.self, from: data)
    }
    
}
