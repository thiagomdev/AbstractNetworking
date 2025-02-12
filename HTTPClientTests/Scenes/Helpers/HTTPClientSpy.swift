import Foundation
@testable import HTTPClient

final class HTTPClientSpy: HTTPClientProtocol {
    private(set) var messages = [(url: URLRequest, completion: (HTTPClientResult) -> Void)]()
    
    var requestedURLs: [URLRequest] { messages.map { $0.url } }
    
    func execute(_ request: URLRequest, onComplete: @escaping (HTTPClientResult) -> Void) {
        messages.append((request, onComplete))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index].url ?? .applicationDirectory,
            statusCode: code,
            httpVersion: nil,
            headerFields: nil
        )!
        messages[index].completion(.success(data, response))
    }
}
