import Foundation

internal final class NetwokingProvider {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
}

extension NetwokingProvider: HTTPClientProtocol {
    func execute(_ request: URLRequest, onComplete: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: request) { data, response, error in
            if let error {
                onComplete(.failure(error))
            }
            guard let data,
                let httpResponse = response as? HTTPURLResponse else {
                return
            }
            onComplete(.success(data, httpResponse))
        }.resume()
    }
}
