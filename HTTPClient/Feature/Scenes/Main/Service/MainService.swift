import Foundation

public enum UnnexpectedError: Error { case unowned }

public enum MainServiceResult {
    case success(DataModel)
    case failure(Error)
}

public protocol MainServicing {
    func fetchData(onComplete: @escaping (MainServiceResult) -> Void)
}

final class MainService {
    private let client: HTTPClientProtocol
    private let strUrl: String = "https://api.themoviedb.org/3/discover/movie"
    
    init(client: HTTPClientProtocol) {
        self.client = client
    }
}

extension MainService: MainServicing {
    func fetchData(onComplete: @escaping (MainServiceResult) -> Void) {
        if let url = URL(string: strUrl) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "accept": "application/json",
                "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIyZjk0NDk4ZDA0ZGFjZDFjZjk2NjQ4YmIxN2NlYmM2NyIsIm5iZiI6MTY5MzQwMDczNS44NjA5OTk4LCJzdWIiOiI2NGVmM2U5Zjk3YTRlNjAwYzQ4NjJjZGIiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.AAAJG3OLN5csc3p4V0MJyNwmMpGbPJcIIU-SwYWDrv8"
            ]
            
            client.execute(request) { result in
                switch result {
                case let .success(data, httpResponse):
                    onComplete(DataModelMapper.map(data, response: httpResponse))
                case let .failure(error):
                    onComplete(.failure(error))
                }
            }
        }
    }
    
    private static var OK_200: Int { 200 }
    
    private enum DataModelMapper {

        static func map(_ data: Data, response: HTTPURLResponse) -> MainServiceResult {
            guard response.statusCode == OK_200,
                let dataModel = try? JSONDecoder().decode(DataModel.self, from: data) else {
                return .failure(UnnexpectedError.unowned)
            }
            return .success(dataModel)
        }
    }
}
