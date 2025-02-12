import Foundation

protocol MainViewModeling {
    func displayData(onComplete: @escaping (MainServiceResult) -> Void)
}

final class MainViewModel {
    private let service: MainServicing
    
    init(service: MainServicing) {
        self.service = service
    }
}

extension MainViewModel: MainViewModeling {
    func displayData(onComplete: @escaping (MainServiceResult) -> Void) {
        service.fetchData { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(dataModel):
                    onComplete(.success(dataModel))
                case let .failure(error):
                    onComplete(.failure(error))
                }
            }
        }
    }
}
