import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClientProtocol {
    func execute(_ request: URLRequest, onComplete: @escaping (HTTPClientResult) -> Void)
}
